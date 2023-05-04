// SPDX-License-Identifier : MIT 

 pragma solidity ^0.8.17;

  contract EcommerceEschrow {
     
     address payable buyer;
     address payable seller;

// this struct holds all the details of the items
     struct item{
         string buyer_name;
         uint unit_no;
         uint total;
         uint price_per_unit;
         string date;
     }
// we are creating this new "product" instance to call the struct
// the main reason is for readability
      item product;

     enum state{
 // this enum tracks the progress of the eschrow
 // if there has been payment, delivery, release of funds, or when everything was finally complete
         Awaiting_payment,
         Awaiting_delivery,
         Awaiting_fund_relase,
         Complete
     }

     state current;
// just like we instantiated "item". we did it again

         uint start;
         uint end;

         uint balance;

         bool buyerApprove;
         bool sellerApprove;
         // this bool confirms if any stuff has been approved

     constructor(address payable _seller) {
         buyer = payable(msg.sender);
         seller = _seller; 
         current = state.Awaiting_payment;       
     }

     function productDetails(string memory _buyer_name, uint units, string memory _date, uint ppu) public {
         product.buyer_name = _buyer_name;
         product.unit_no = units;
         product.date = _date;
         product.price_per_unit = ppu;
     }    
     
// this serves as the fallback function to receive funds
     function putFundsInEschrow() payable external {
         require(msg.sender == buyer, "Only the buyer can do this");
         require(current == state.Awaiting_payment, "The buyer has paid");
         require(msg.value > product.total, "The amount is less than total");

         balance = msg.value;
         start = block.timestamp;
         current = state.Awaiting_delivery;
     }

     function sellerSendProduct() public{
         require(msg.sender == buyer);
         require(current == state.Awaiting_delivery);

         sellerApprove = true;
     }

     function buyerReceiveDelivery() public {
         require(msg.sender == buyer);
         require(current == state.Awaiting_payment);

         buyerApprove = true;
         current = state.Awaiting_fund_relase;

         if(sellerApprove == true) {
           releaseFund;
         }
     }
    
     function getBalance() public view returns (uint) {
         return address(this).balance;
     }

     function releaseFund() private {
         if(buyerApprove && sellerApprove){

         seller.transfer(address(this).balance);
         current = state.Complete;
         }

     }

     function withdrawFunds() public payable{
         end = block.timestamp;

         require(msg.sender == buyer);
         require(current == state.Awaiting_delivery);

         if(buyerApprove == false && sellerApprove == true){
          
          seller.transfer(address(this).balance);
          
          } else if (buyerApprove &&! sellerApprove && end> start + 172800) {
            
            require(address(this).balance != 0, "The money has been transferred already");
          
          buyer.transfer(address(this).balance);
          }
     
     current = state.Complete;    
     
     }

  }
