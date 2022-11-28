asuse dep::std;

global CANDIDATE_COUNT = 10;
global VOTER_COUNT = 2;
global ALL_VOTES_COUNT = 20; // CANDIDATE_COUNT * VOTER_COUNT

fn check_commitments(
    commitments: [Field; VOTER_COUNT],
    secrets: [Field; VOTER_COUNT],
    all_votes: [u32; ALL_VOTES_COUNT],
) {
    for i in 0..VOTER_COUNT {
        let mut transcript = [0; CANDIDATE_COUNT + 1];
        transcript[0] = secrets[i];
        for j in 0..CANDIDATE_COUNT {
            transcript[j + 1] = all_votes[i * CANDIDATE_COUNT + j] as Field;
        };
        constrain commitments[i] == std::hash::pedersen(transcript)[0];
    };
}

fn sum_votes(
    all_votes: [u32; ALL_VOTES_COUNT],
) -> [u32; CANDIDATE_COUNT] {
    let mut totals = [0; CANDIDATE_COUNT];
    for i in 0..VOTER_COUNT {
        for j in 0..CANDIDATE_COUNT {
            totals[j] = totals[j] + all_votes[i * CANDIDATE_COUNT + j];
        }
    };
    totals
}

fn main(
    commitments: pub [Field; VOTER_COUNT],
    all_votes: [u32; ALL_VOTES_COUNT],
    secrets: [Field; VOTER_COUNT],
) -> pub [u32; CANDIDATE_COUNT] {
    check_commitments(commitments, secrets, all_votes);
    sum_votes(all_votes)
}