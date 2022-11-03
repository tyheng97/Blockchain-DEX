// struct NewOrder{
//         address maker;
//         uint256 amount;
//         uint256 rate;
//     }
   
//     uint256 public buyCounter = 0;
//     uint256 public minSellRate;
//     mapping(uint256=> NewOrder) public newBuyOrderBook; //   [idofbuyrate] [address amount rate]
//     uint256[] public arrayBuyID
//     uint256 public idOfBuyRate;

//     uint256 public sellCounter = 0;
//     mapping(uint256=> NewOrder) public newSellOrderBook;
//     uint256 public idOfSellRate;
//     uint256 public maxBuyRate;
//     uint256 public selltx = 0;


//        function newplaceBuyOrder(uint256 a, uint256 b) external override nonReentrant{
//         require(coolToken.balanceOf(msg.sender) >= amountOfSellToken);

//         coolToken.transferFrom(msg.sender, address(this), amountOfSellToken);
//         emit PlaceBuyOrder(msg.sender, amountOfBuyToken, amountOfSellToken);

//         uint256 rate = amount/amountOfBuyToken;
//         uint256 sellRate = minSellRate;
//         uint256 amountSold = amount;
//         if (rate >= minSellRate && minSellRate > 0){
//             //give best order
//             if (newSellOrderBook[idOfSellRate].amount > amount){
//                 uint256 newAmount = newSellOrderBook[idOfSellRate].amount - amount;
//                 newSellOrderBook[idOfSellRate].amount = newAmount; //replace old amount with new
//                 // transfer 
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, amount);
//                 secondToken.transfer(msg.sender, amount);
//             }

//             if (newSellOrderBook[idOfSellRate].amount == amount){
//                 // transfer 
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, amount);
//                 secondToken.transfer(msg.sender, amount);
//                 // update the minSellRate
//                 delete newSellOrderBook[idOfSellRate];


//             }
//             if (newSellOrderBook[idOfSellRate].amount < amount){
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, newSellOrderBook[idOfSellRate].amount);
//                 secondToken.transfer(msg.sender, amount);
//             }




//         }
//         if (amountSold > 0){
//             _addToBuyBook(rate, amountSold);
//         }
//     }


//     function maxNumber(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a >= b ? a : b;
//     }
//     function minNumber(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a <= b ? a : b;
//     }

//       function _addToBuyBook(uint256 rate, uint256 amountSold) internal{
//         require(rate > 0);
//         buyCounter += 1;
//         arrayBuyID.push[buyCounter]
//         maxBuyRate = maxNumber(maxBuyRate, rate);
//         if (maxBuyRate == rate){
//             idOfBuyRate = buyCounter;
//         }

//         newBuyOrderBook[buyCounter] = NewOrder(msg.sender, amountSold, rate);
//         selltx += 1;

//         emit DrawToBuyBook(msg.sender, rate, amountSold);


//     }

//     function newplaceSellOrder(uint256 amountOfBuyToken, uint256 amountOfSellToken, uint256 amount) external override nonReentrant{
//         require(secondToken.balanceOf(msg.sender) >= amountOfSellToken);
//         secondToken.transferFrom(msg.sender, address(this), amountOfSellToken);
//         emit PlaceSellOrder(msg.sender, amountOfBuyToken, amountOfSellToken);

//         uint256 rate = amount/amountOfBuyToken;
//         rate = 1/rate;
//         uint256 sellRate = minSellRate;
//         uint256 amountSold = amount;
//         if (rate <= maxBuyRate && maxBuyRate>0){
            
//             if (newSellOrderBook[idOfSellRate].amount > amount){
//                 uint256 newAmount = newSellOrderBook[idOfSellRate].amount - amount;
//                 newSellOrderBook[idOfSellRate].amount = newAmount; //replace old amount with new
//                 // transfer 
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, amount);
//                 secondToken.transfer(msg.sender, amount);
//             }

//             if (newSellOrderBook[idOfSellRate].amount == amount){
//                 // transfer 
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, amount);
//                 secondToken.transfer(msg.sender, amount);
//                 // update the minSellRate
//                 delete newSellOrderBook[idOfSellRate];

//                 uint8 i = 0;
//                 uint256 nextPrice = 0;
//                 // minSellRate = 
//                 // while(i < selltx){
//                 //     if(newSellOrderBook[i].rate<)
//                 // }


//             }
//             if (newSellOrderBook[idOfSellRate].amount < amount){
//                 coolToken.transfer(newSellOrderBook[idOfSellRate].maker, newSellOrderBook[idOfSellRate].amount);
//                 secondToken.transfer(msg.sender, amount);
//             }
//         }
//         if (amountSold > 0){
//             _addToSellBook(rate, amountSold);
//         }
//     }

//     function _addToSellBook(uint256 rate, uint256 amountSold) internal{
//         require(rate > 0);
//         sellCounter += 1;
//         minSellRate = minNumber(minSellRate, rate);
//         if (minSellRate == rate){
//             idOfSellRate = sellCounter;
//         }

//         newSellOrderBook[sellCounter] = NewOrder(msg.sender, amountSold, rate);
//         emit DrawToSellBook(msg.sender, rate, amountSold);


//     }
