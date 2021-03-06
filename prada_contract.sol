pragma solidity ^0.4.24;

contract  Prada_product { 
    
   struct Product {
     string name;
     string description;
     string manufacturer;
     bool initialized;
   }
   
   struct Manufacturer {
     string license;
     bool initialized;
   }
   
   event ProductCreate(address account, string uuid, string manufacturer);
   event ProductTransfer(address from, address to, string uuid);
   event RejectCreate(address account, string uuid, string message);
   event RejectTransfer(address from, address to, string uuid, string message);
   event AddManufacturer(address from,  string message);
   event RejectAddManufacturar(address from, string message);
   event RejectDeleteManufacturar(address from, string message);
   event DeleteManufacturar(address from, string message);
   
   mapping(string  => Product) private productStore;
   
   mapping(address => mapping(string => bool)) private walletStore;
   
   mapping(address => Manufacturer) private manufacturer;
   
   address owner;
   
   constructor () public { 
       owner=msg.sender; 
   }
  
    modifier onlyOwner {
       require(msg.sender == owner);
       _; 
    }
    
    modifier onlyManufacturar {
         require(manufacturer[msg.sender].initialized == true);
         _; 
    }


   function addManufacturer(address _manufacturer , string license) onlyOwner public {
         if(manufacturer[_manufacturer].initialized){
             emit RejectAddManufacturar(msg.sender, "Manufacturar already added");
             revert("Manufacturar already added");
             return;
         }
         
         manufacturer[_manufacturer] = Manufacturer(license, true);
         emit AddManufacturer(msg.sender, "Manufacturer added successfully");
   }
   
  function removeManufacturer(address _manufacturer) onlyOwner public {
      if(manufacturer[_manufacturer].initialized){
          manufacturer[_manufacturer].initialized =  false;
          emit DeleteManufacturar(msg.sender, "Manufecturar deleted");
          return;
       }
       emit RejectDeleteManufacturar(msg.sender, "Manufecturar already deleted");
       revert("Manufacturar already deleted");
       return;
  }
   
    
   function createProduct(string name, string description, string uuid, string manufacturerName) onlyManufacturar  public {
      if(productStore[uuid].initialized) {
        emit RejectCreate(msg.sender, uuid, "Asset with this UUID already exists.");
        revert("Asset with this UUID already exists");
        return;
      }

      productStore[uuid] = Product(name, description, manufacturerName, true );
      walletStore[msg.sender][uuid] = true;
      emit ProductCreate(msg.sender, uuid, manufacturerName);
   }
    
    function transferProduct(address to, string uuid)  public {
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
       return (productStore[uuid].name, productStore[uuid].description, productStore[uuid].manufacturer, productStore[uuid].initialized );
    }
    
    function getManufacturar(address _address) public constant returns (string, bool){
       return (manufacturer[_address].license, manufacturer[_address].initialized);
    }
    
    function isOwnerOf(address _owner, string uuid) public constant returns (bool) {
         if(walletStore[_owner][uuid]) {
           return true;
          }
         revert("Product does not exist");
         return false;
     }
}
