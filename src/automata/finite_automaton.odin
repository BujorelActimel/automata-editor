package automata

DFA :: struct {
    states:       []string,
    alphabet:     []u8,
    transitions:  [][256]int, // [from][symbol] = to, -1 = dead
    initial:      int,
    accepting:    []bool,
}

NFA :: struct {
    states:      []string,
    alphabet:    []u8,
    transitions: [][256][]int, // [from][symbol] = []to
    epsilon:     [][]int,      // [from] = []to via epsilon
    initial:     int,
    accepting:   []bool,
}

DFA_Step :: struct {
    state: int,
    pos:   int,
}

NFA_Step :: struct {
    states: []int,
    pos:    int,
}

is_deterministic :: proc(aut: NFA) -> bool {
    for epsilon_targets in aut.epsilon {
        if len(epsilon_targets) != 0 do return false
    }
    for state_transitions in aut.transitions {
        for symbol in aut.alphabet {
            if len(state_transitions[symbol]) > 1 do return false
        }
    }
    return true
}

is_complete :: proc(aut: DFA) -> bool {
    for state_transitions in aut.transitions {
        for symbol in aut.alphabet {
            if state_transitions[symbol] == -1 {
                return false
            }
        }
    }
    return true
}

accepts_dfa :: proc(aut: DFA, input: []u8) -> bool {
    current := aut.initial
    for symbol in input {
        current = aut.transitions[current][symbol]
        if current == -1 do return false
    }
    return aut.accepting[current]
}

epsilon_closure :: proc(aut: NFA, active: []bool) {
    changed := true
    for changed {
        changed = false
        for state in 0..<len(aut.states) {
            if !active[state] do continue
            for to in aut.epsilon[state] {
                if !active[to] {
                    active[to] = true
                    changed = true
                }
            }
        }
    }
}

accepts_nfa :: proc(aut: NFA, input: []u8) -> bool {
    active := make([]bool, len(aut.states))
    next   := make([]bool, len(aut.states))
    defer delete(active)
    defer delete(next)

    active[aut.initial] = true
    epsilon_closure(aut, active)

    for symbol in input {
        for i in 0..<len(next) do next[i] = false

        for state in 0..<len(aut.states) {
            if !active[state] do continue
            for to in aut.transitions[state][symbol] {
                next[to] = true
            }
        }
        active, next = next, active
        epsilon_closure(aut, active)
    }

    for state in 0..<len(aut.states) {
        if active[state] && aut.accepting[state] do return true
    }
    return false
}

accepts :: proc { accepts_dfa, accepts_nfa }

// simulate_dfa :: proc(aut: DFA, input: []u8) -> []DFA_Step {
//     for symbol in input {

//     }
// }

// simulate_nfa :: proc(aut: NFA, input: []u8) -> []NFA_Step {

// }

// simulate :: proc { simulate_dfa, simulate_nfa }
