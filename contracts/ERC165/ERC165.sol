pragma solidity 0.5.8;

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
interface ERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
