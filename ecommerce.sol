// SPDX-License-Identifier: MIT 
// SPDX-License-identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract ecommerce{
    int public revenue;
    string public ownerName;
    address public owner;

    struct product {
        uint prodID;
        string prodName;
        int itemQuant;
        int unitCost;
        int unitSold;
    }

    product[] public productList;
    int public totalProducts;

    struct transaction{
        address buyer;
        uint prodID;
        int itemQuant;
        int unitCost;
    }

    mapping (int => transaction) public transactionList;
    int transactionID = -1;

    constructor() payable{
        ownerName="Kyle";
        revenue=0;
        owner=msg.sender;
    }

    function addProduct(uint ID, string memory name, int quant, int cost) public {
        product memory newProduct;
        newProduct = product(ID, name, quant, cost,0);
        productList.push(newProduct);
        totalProducts=totalProducts+1;
    }

    function purchaseItem(uint ID, int quant) public payable returns (bool, bytes memory) {
        int cost;
        bool success;
        bytes memory data;
        cost=productList[ID].unitCost*quant;
        require(productList[ID].itemQuant>=quant, "out of stock");
        require(msg.value>=uint(cost), "balance too low");
        (success, data) = owner.call{value: uint(cost)}("");
        productList[ID].itemQuant=productList[ID].itemQuant-quant;
        productList[ID].unitSold=productList[ID].unitSold+quant;
        revenue=revenue+cost;
        transactionID+=1;
        transactionList[transactionID]=transaction(msg.sender,ID,quant,productList[ID].unitCost);
        return (success, data);
    }

    function returnItem(uint ID, int quant, address custAddress) public payable returns (bool, bytes memory) {
        int cost;
        bool success;
        bytes memory data;
        cost=productList[ID].unitCost*quant;
        require(msg.sender==owner, "you are not authorized");
        (success, data) = custAddress.call{value: uint(cost)}("");
        productList[ID].itemQuant=productList[ID].itemQuant+quant;
        revenue=revenue-cost;
        return (success, data);
    }

    function changePrice(uint ID, int price) public {
        productList[ID].unitCost=productList[ID].unitCost+price;
    }

    function addItem(uint ID, int quant) public {
        productList[ID].itemQuant=productList[ID].itemQuant+quant;
   
    }

    function mostPopularProduct() view public returns (int num, uint ID){
        int mostSold = 0;
        uint mostPopularID;
        int i = 0;
        while (i < totalProducts){
            if (mostSold < productList[uint(i)].unitSold){
                mostSold = productList[uint(i)].unitSold;
                mostPopularID = productList[uint(i)].prodID;
            }
            i++;
        }
        return (mostSold,mostPopularID);
    }

    function getBalance() public view returns (int) {
        return (int) (owner.balance);
    }
}