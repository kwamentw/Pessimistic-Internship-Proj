// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";

library Items {
    using Items for ItemId;

    struct ItemId {
        bytes4 class;
        bytes data;
    }

    struct Item {
        ItemId id;
        uint256 value;
    }

    function token(ItemId memory self) internal pure returns (address) {
        return abi.decode(self.data, (address));
    }

    function hash(Items.ItemId[] memory itemIds) internal pure returns (bytes32) {
        return keccak256(abi.encode(itemIds));
    }

    function deposit(
        Items.Item memory item,
        uint256 amount
    ) external {
        address itemToken = item.id.token();

        IERC20(itemToken).transferFrom(msg.sender, address(this), amount);
    }
}

library Placements {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using Items for Items.Item;

    struct Placement {
        Items.Item[] items;
        address sender;
        address beneficiary;
        uint32 deadline;
        uint256 fee;
    }

    struct Registry {
        CountersUpgradeable.Counter placementIdTracker;
        mapping(uint256 => Placement) placements;
    }

    function register(Registry storage self, Placement memory placement) external returns (uint256 placementId) {
        self.placementIdTracker.increment();

        Placement storage placementRecord = self.placements[placementId];

        placementRecord.sender = placement.sender;
        placementRecord.beneficiary = placement.beneficiary;
        placementRecord.deadline = placement.deadline;

        for (uint256 i = 0; i < placement.items.length; i++) {
            placementRecord.items.push(placement.items[i]);
            placement.items[i].deposit(placement.fee);
        }
    }
}

abstract contract ManagerStorage {
    Placements.Registry internal _placementRegistry;
}

// solution #1 - i.e the contract initializing palcements
contract PlacementInitializer is ManagerStorage{
    function resetCounter() internal {
        _placementRegistry.placementIdTracker = CountersUpgradeable.Counter(0);
    }

    function register(Placements.Placement memory newPlacement) external returns(uint256 placementId){
        resetCounter();
        placementId = Placements.register(_placementRegistry,newPlacement);
    }

    function viewPlacement(uint256 placementId) external view returns(Placements.Placement memory record){
        record = _placementRegistry.placements[placementId];
    }
}

// solution #2 - Are the items at line 73 in the Placements contract added correctly? Why? (Give a detailed explanation)
/**
 * No they are not being added correctly and the root cause is from the placementId
 * The issue is;
 * the placementId variable is uninitialized 
 * but from line 64 we can see that there is a placementIdtracker
 * which is meant to track the value of placementid
 * but here is the case placementId is not initialised to the tracker 
 * making the values of the return value out of sync and incorrect
 * This will result in unexpected behavior and errors when pushing items on line 73
 * and also it will return an invalid value at the end of the function
 * 
 * //// BOUNS ////
 * on line 74 the placement fee being added 
 * the fee charged on all items will be the same for each item in the loop
 * i see it is intended design 
 * but shouldn't this design allow different charge for each item? since they are of different value
 */

// solution #3 - What is the purpose of using Items for ItemtId in Items library?
/**
 * From the library `Items`, on line 15
 * we can observe that on the next line theres is a `using Items for ItemId;` statement there
 * This means that this library makes use of a ItemId struct implemented by the same library i.e:
 * the library declares `struct ItemId` with two fields of type bytes4 and bytes
 * Moving on to the next struct declaration on line 23 in the library `Items`
 * we can observe that the `struct Item` has two fields of type ItemId and uint256
 * uint256 that is the standard data type we all know but
 * ItemId is the same ItemId we declared on line 28
 * How is this possible?
 * Libraries create reusable code as a result the struct ItemId can be reused even by the same libary
 * and it is valid to use in the same library when you declare the intent just like on line 16
 * So the Purpose of line 16 is to facilitate the use of `ItemId` in `Item`
 */