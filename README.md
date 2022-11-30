# Quadratic Voting with Noir

A simple example allowing users to cast ballots—constrained by QV rules—without revealing their preferences to anyone but a trusted ballot manager. The ballot manager is unable to censor of modify the votes. This example focuses on the zk circuits, which in practice would need to be coordinated by a consensus mechanism such as by validating on a blockchain.

## Circuits

### Cast Ballot (user circuit)

- Enforces Quadratic Voting's cost function
- Outputs a commitment for the user to share publicly

### Count Votes (manager circuit)

- Enforces that all committed votes are counted
- Outputs the vote totals to share publicly

## Usage

The circuits can be built, proved and verified using `nargo`.
