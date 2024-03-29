// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

error NotOwner();
contract UniqueAddress {
    mapping(uint256 => uint256) private addressToAmountFunded;
    uint256[] private uniqueAddress;

    function addUniqueAddress(uint256 _value) public {
        require(addressToAmountFunded[_value] == 0, "Value already exists in array");
        
        // Add the value to the uniqueArray
        uniqueAddress.push(_value);

        // Store the index of the value in the valueToIndex mapping
        addressToAmountFunded[_value] = uniqueAddress.length;
    }

    function getUniqueAddress() public view returns (uint256[] memory) {
        return uniqueAddress;
    }
}

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    
    address public i_owner;
    uint256 public constant MINIMUM_ETH = 0.01 ether;
    
    constructor() {
        i_owner = msg.sender;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == i_owner, "Only the owner can transfer ownership");
        require(newOwner != address(0), "Invalid address");
        i_owner = newOwner;
    }
    function fund() public payable {
        require(msg.value >= MINIMUM_ETH, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

