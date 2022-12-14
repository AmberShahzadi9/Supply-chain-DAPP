pragma solidity ^0.4.24;

import "../MedicineAccesscontrol/DistributorRole.sol";
import "../MedicineAccesscontrol/ManufacturerRole.sol";
import "../MedicineAccesscontrol/PharmacistRole.sol";
import "../Medicinecore/Ownable.sol";


// Define a contract 'Supplychain'
contract SupplyChain is Ownable, ManufacturerRole, DistributorRole, PharmacistRole {

// // Define a variable called 'ndc' for National Drug Code (NDC)
// uint  ndc;

// // Define a variable called 'sku' for Stock Keeping Unit (SKU)
uint  sku;

// Define a public mapping 'items' that maps the NDC to an Item.
mapping (string => Item) items;

// Define a public mapping 'itemsHistory' that maps the NDC to an array of TxHash,
// that track its journey through the supply chain -- to be sent from DApp.
mapping (uint => string[]) itemsHistory;

// Define enum 'State' with the following values:
enum State
{

  Ordered,  //0
  Manufactured, //1
  MfrDispatched, //2
  DistrReceived, //3
  DistrDispatched, //4
  PharReceived, //5
  Dispensed   //6
  }
State constant defaultState = State.Manufactured;

// Define a struct 'Item' with the following fields:
struct Item {

  uint    sku;  // Stock Keeping Unit (SKU)
  string    ndc; //  National Drug Code (NDC) generated by the Manufacturer(10 digit), goes on the package, n be used for verification

  address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through stages
  address manufacturerID;
  address distributorID;  // Metamask-Ethereum address of the Distributor
  address pharmacistID; // Metamask-Ethereum address of the Pharmacist

  string  productID;  // Product ID
  string  productDescription; // Product Description
  string  productFormName; // Product Form like Tablet,Injection
  string  productLabelerName; // Product Manufacturer Details
  //uint    productPrice; // Product Price

  State   itemState;  // Product State as represented in the enum above
 
}
 // Define events with the same state values and accept 'ndc' as input argument

 event Ordered(string ndc);
 event Manufactured(string ndc);
 event MfrDispatched(string ndc);
 event DistrReceived(string ndc);
 event DistrDispatched(string ndc);
 event PharReceived(string ndc);
 event Dispensed(string ndc);

  //Define a modifier that checks if an item.state of a ndc is Manufactured

  modifier manufactured(string _ndc) {
    require(items[_ndc].itemState == State.Manufactured,"Item not manufactured!");
    _;
  }

  // Define a modifier that checks if an item.state of a ndc is Ordered
  modifier ordered(string _ndc) {
    require(items[_ndc].itemState == State.Ordered,"Item not ordered");
    _;
  }

  // Define a modifier that checks if an item.state of a ndc is Received
  modifier distReceived(string _ndc) {
    require(items[_ndc].itemState == State.DistrReceived,"Item not received");
    _;
  }

  // Define a modifier that checks if an item.state of a ndc is MfrDispatched
  modifier mfrDispatch(string _ndc) {
    require(items[_ndc].itemState == State.MfrDispatched,"Item in Production");
    _;
  }

  modifier distDispatch(string _ndc) {
    require(items[_ndc].itemState == State.DistrDispatched,"Item not dispatched to Distributor");
    _;
  }

  modifier pharReceived(string _ndc) {
    require(items[_ndc].itemState == State.PharReceived,"Item not received");
    _;
  }

  // Define a modifier that checks if an item.state of a ndc is Dispensed
  modifier dispenseItem(string _ndc) {
    require(items[_ndc].itemState == State.Dispensed,"Item not dispensed");
    _;
  }


  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  constructor() public payable {
  sku = 1;
  }

  // Define a function 'kill' if required
  function kill() public onlyOwner(){
    
      selfdestruct(owner());
    
  }

//Define a function 'manufactureItem' that allows a Maufacturer to mark it as 'Manufactured'

function manufactureItem(string _ndc,address _manufacturerID, 
string memory _productID, string memory _productDescription, 
string memory _productFormName, string memory _productLabelerName) public onlyManufacturer 
 {
  items[_ndc].manufacturerID = _manufacturerID;
  items[_ndc].productID = _productID;
  items[_ndc].productDescription = _productDescription;
  items[_ndc].productFormName = _productFormName;
  items[_ndc].productLabelerName = _productLabelerName;
  //items[_ndc].productPrice = _productPrice;
  items[_ndc].ndc = _ndc;
  items[_ndc].sku = sku;
  items[_ndc].ownerID = _manufacturerID;
  items[_ndc].itemState = State.Manufactured;
  sku = sku + 1;
  emit Manufactured(_ndc);
}

//Define a function 'dispatchItem' that allows a Manufacturer to mark it as MfrDispatched

function dispatchItemToDistr(string _ndc) public onlyManufacturer manufactured(_ndc){
  items[_ndc].itemState = State.MfrDispatched;
  emit MfrDispatched(_ndc);
}

//Define a function 'receiveItem' that allows a Distributor to mark it as Received

function distrReceiveItem(string _ndc) public onlyDistributor mfrDispatch(_ndc) {
  address receiver = msg.sender;
  items[_ndc].ownerID = receiver;
  items[_ndc].distributorID = receiver;
  items[_ndc].itemState = State.DistrReceived;
  emit DistrReceived(_ndc);
}

function dispatchItemToPharmacist(string _ndc) public onlyDistributor distReceived(_ndc) {
  items[_ndc].itemState = State.DistrDispatched;
  emit DistrDispatched(_ndc);
}

function pharReceiveItem(string _ndc) public onlyPharmacist
distDispatch(_ndc) {
  address receiver = msg.sender;
  items[_ndc].ownerID = receiver;
  items[_ndc].pharmacistID = receiver;
  items[_ndc].itemState = State.PharReceived;
  emit PharReceived(_ndc);
}

function dispenseToConsumer(string _ndc) public onlyPharmacist
pharReceived(_ndc) {
  items[_ndc].itemState = State.Dispensed;
  emit Dispensed(_ndc);
}

// Define a function 'fetchItemBufferOne' that fetches the data
function fetchItemBufferOne(string _ndc) public view returns
(
uint    itemSKU,
string    itemNDC,
address ownerID,
address manufacturerID,
string  memory productID,
string  memory productDescription,
string  memory productFormName,
string  memory productLabelerName
)
{
// Assign values to the 8 parameters
itemSKU = items[_ndc].sku;
itemNDC = items[_ndc].ndc;
ownerID = items[_ndc].ownerID;
manufacturerID = items[_ndc].manufacturerID;
productID = items[_ndc].productID;
productDescription = items[_ndc].productDescription;
productFormName = items[_ndc].productFormName;
productLabelerName = items[_ndc].productLabelerName;
return
(
itemSKU,
itemNDC,
ownerID,
manufacturerID,
productID,
productDescription,
productFormName,
productLabelerName
);
}
// Define a function 'fetchItemBufferTwo' that fetches the data
function fetchItemBufferTwo(string _ndc) public view returns
(
uint    itemSKU,
string    itemNDC,
uint    itemState,
address distributorID,
address pharmacistID
)
{
  // Assign values to the 9 parameters
  itemSKU = items[_ndc].sku;
itemNDC = items[_ndc].ndc;
itemState = uint(items[_ndc].itemState);
distributorID = items[_ndc].distributorID;
pharmacistID = items[_ndc].pharmacistID;
return
(
itemSKU,
itemNDC,
itemState,
distributorID,
pharmacistID
);
}
}