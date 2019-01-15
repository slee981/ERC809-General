## ERC809
ERC809 provides an interface for renting out access to tokenized assets. This implementation allows for both fungible and non-fungible interpretations, and further, allows for renting of arbitrary duration without inflating the associated gas cost.

## Quick Test
Clone this repository, cd into proper directory. In another terminal, cd into the same directory and enter:
```
$ npm install
$ truffle dev
```
In your first terminal, test that code executes by typing:
```
$ truffle test
```
This should pass all 31 tests.

## Future
The idea is to allow simple tokenization of rentable assets by inheriting "RentableAsset.sol" and "ERC809.sol". For example, if you want to rent hotel rooms, you would have a Room represented by:
```
contract Room is RentableAsset {
  /* room stuff */
}
```
And similarly allow for a Hotel to act as that Room's manager by typing:
```
contract Hotel is ERC809 {
  /* hotel stuff */
}
```
The next step is to allow for bundling reservations together with better deals.

## Contact
This is still in demo phase, do not use as is! For questions or discussion, please contact me at steven@booklocal.in.
