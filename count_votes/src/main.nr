use dep::std;

// The number of candidates on each ballot
global CANDIDATE_COUNT = 10;
// The number of voters' ballots to be aggregated
global VOTER_COUNT = 2;

// Recalculate each commitment to prove consistency. The contents
// of each input array should follow a consistent user ordering.
fn check_commitments(
    // Each user's existing commitment to match
    commitments: [Field; VOTER_COUNT],
    // Each user's ballot secret
    secrets: [Field; VOTER_COUNT],
    // Flattened 2D array of each users' ballots
    all_votes: [u32; VOTER_COUNT * CANDIDATE_COUNT],
) {
    // Iterate each user
    for i in 0..VOTER_COUNT {
        // Form each transcript by prepending the user's secret
        let mut transcript = [0; CANDIDATE_COUNT + 1];
        transcript[0] = secrets[i];
        for j in 0..CANDIDATE_COUNT {
            // Flattened 2D array index arithmetic
            // Pedersen expects a transscript of Field elements, hence the cast
            transcript[j + 1] = all_votes[i * CANDIDATE_COUNT + j] as Field;
        };
        // Enforce consistency with the provided commitment
        constrain commitments[i] == std::hash::pedersen(transcript)[0];
    };
}

// Sum the votes of each candidate in a 2D array of ballots
fn sum_votes(
    // Flattened 2D array of each users' ballots
    all_votes: [u32; VOTER_COUNT * CANDIDATE_COUNT],
) -> [u32; CANDIDATE_COUNT] {
    // Sums of each "column" get aggregated into this array
    let mut totals = [0; CANDIDATE_COUNT];
    for i in 0..VOTER_COUNT {
        for j in 0..CANDIDATE_COUNT {
            // Flattened 2D array index arithmetic
            totals[j] = totals[j] + all_votes[i * CANDIDATE_COUNT + j];
        }
    };
    // Return the aggregated totals
    totals
}

// Totals the votes for each candidate whilst checking that ballots
// are consistent with their prior commitments. The contents of each
// input array should follow a consistent user ordering.
fn main(
    // The public ballot commitments made by each voter
    commitments: pub [Field; VOTER_COUNT],
    // A flattened 2D array of each users' votes
    // Note: unflattened 2D array aren't yet supported by the ABI
    all_votes: [u32; VOTER_COUNT * CANDIDATE_COUNT],
    // Each user's ballot secret
    secrets: [Field; VOTER_COUNT],
) -> pub [u32; CANDIDATE_COUNT] {
    // Enforce prior commitments to prevent censorship or tampering
    check_commitments(commitments, secrets, all_votes);
    // Reveal the final result
    sum_votes(all_votes)
}