use dep::std;

global CANDIDATE_COUNT = 2;
global VOTER_COUNT = 10;

fn compute_root_from_leafs(leafs: [Field; VOTER_COUNT]) -> Field {
    leafs[0] // TODO
}

fn check_root_hash(
    onchain_root_hash: Field,
    hashes: [Field; VOTER_COUNT],
) {
    let circuit_root_hash = compute_root_from_leafs(hashes);
    constrain onchain_root_hash == circuit_root_hash;
}

fn sum_votes(all_votes: [[u32; CANDIDATE_COUNT]; VOTER_COUNT]) -> [u32; CANDIDATE_COUNT] {
    let mut summed_votes = [0; CANDIDATE_COUNT];
    for i in 0..CANDIDATE_COUNT {
        for j in 0..VOTER_COUNT {
            summed_votes[i] = summed_votes[i] + all_votes[j][i];
        };
    };
    summed_votes
}


fn announce_winner(summed_votes: [u32]) -> Field {
    let mut winner = 0;
    for i in 1..std::array::len(summed_votes) {
        if summed_votes[i] > summed_votes[i-1] {
            winner = i;
        };
    };
    winner
    // TODO: Handle multiple winners with same vote counts.
}

fn hash_votes(
    votes: [u32; CANDIDATE_COUNT],
    secret: Field,
) -> Field {
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    for i in 0..CANDIDATE_COUNT {
        transcript[i] = votes[i] as Field;
    };
    
    transcript[CANDIDATE_COUNT + 1] = secret;
    
    let hash = std::hash::pedersen(transcript)[0];
    hash
}

fn main(
    onchain_root_hash: pub Field,
    all_votes: [[u32; CANDIDATE_COUNT]; VOTER_COUNT],
    all_secrets: [Field; VOTER_COUNT],
) -> pub Field {
    let mut hashes = [0; VOTER_COUNT];
    for i in 0..VOTER_COUNT {
        hashes[i] = hash_votes(all_votes[i], all_secrets[i]);
    };
    check_root_hash(onchain_root_hash, hashes);
    announce_winner(sum_votes(all_votes))
}