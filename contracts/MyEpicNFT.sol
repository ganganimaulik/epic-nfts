// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libs/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

    mapping(string => string[]) words;
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. dingdong!");
        words["FIRST_WORD"] = [
            "safari",
            "hardhat",
            "truffle",
            "solidity",
            "vscode",
            "sublime",
            "nft",
            "windows",
            "github"
        ];
        words["SECOND_WORD"] = [
            "ethereum",
            "bitcoin",
            "polygon",
            "bitbucket",
            "metic",
            "avalanche",
            "metamask",
            "dao",
            "macos"
        ];
        words["THIRD_WORD"] = [
            "wallet",
            "gitcoin",
            "keyboard",
            "mouse",
            "laptop",
            "mobile",
            "application",
            "defi",
            "linux"
        ];
    }

    function pickRandomWord(string memory word_number, uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked(word_number, Strings.toString(tokenId)))
        );
        rand = rand % words[word_number].length;
        return words[word_number][rand];
    }

    function makeAnEpicNFT() public {
        require(
            _tokenIds.current() < 10,
            "There are already 10 Epic NFTs. You can't make any more."
        );
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();
        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomWord("FIRST_WORD", newItemId);
        string memory second = pickRandomWord("SECOND_WORD", newItemId);
        string memory third = pickRandomWord("THIRD_WORD", newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        ); // Actually mint the NFT to the sender using msg.sender.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(msg.sender, newItemId);

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
        _setTokenURI(newItemId, finalTokenUri);
        emit NewEpicNFTMinted(msg.sender, newItemId);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }
}
