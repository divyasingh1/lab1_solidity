pragma solidity ^0.4.24;

contract  Prada_product { 
    
   struct Product {
    string name;
    string description;
    string manufacturer;
    bool initialized; 
}
   
   event ProductCreate(address account, string uuid, string manufacturer);
   event ProductTransfer(address from, address to, string uuid);
   event RejectCreate(address account, string uuid, string message);
   event RejectTransfer(address from, address to, string uuid, string message);
   
   mapping(string  => Product) private productStore;
   
   mapping(address => mapping(string => bool)) private walletStore;
   
   constructor () public { 
   }
    
    
   function createProduct(string name, string description, string uuid, string manufacturer) public{
      if(productStore[uuid].initialized) {
        emit RejectCreate(msg.sender, uuid, "Asset with this UUID already exists.");
        revert("Asset with this UUID already exists");
        return;
      }

      productStore[uuid] = Product(name, description, manufacturer, true);
      walletStore[msg.sender][uuid] = true;
      emit ProductCreate(msg.sender, uuid, manufacturer);
   }
    
    function transferProduct(address to, string uuid) public {
        if(!productStore[uuid].initialized) {
          emit RejectTransfer(msg.sender, to, uuid, "No asset with this UUID exists");
          revert("No asset with this UUID exists");
          return;
        }

        if(!walletStore[msg.sender][uuid]) {
           emit RejectTransfer(msg.sender, to, uuid, "Sender does not own this asset.");
           revert("Sender does not own this asset.");
           return;
        }

        walletStore[msg.sender][uuid] = false;
        walletStore[to][uuid] = true;
        emit ProductTransfer(msg.sender,  to, uuid);
    }
    
    function getProductByProductId(string uuid) public constant returns (string, string, string, bool) {
       return (productStore[uuid].name, productStore[uuid].description, productStore[uuid].manufacturer, productStore[uuid].initialized);
    }
    
    function isOwnerOf(address owner, string uuid) public constant returns (bool) {
         if(walletStore[owner][uuid]) {
           return true;
          }
         revert("Product does not exist");
         return false;
     }
}
