module game::allocation;

// === Imports ===
use game::{
    asui::{Self, ASUI},
    bsui::{Self, BSUI},
};

use sui::{
    coin::{TreasuryCap},
};

// === Admin Functions ===

public fun allocate<CoinT>(
    treasury_cap: &mut TreasuryCap<CoinT>,
    addresses: vector<address>,
    ctx: &mut TxContext,
){
    addresses.do!(| address | {
        let coin = treasury_cap.mint(10_000_000_000, ctx);
        transfer::public_transfer(coin, address);
    });
}