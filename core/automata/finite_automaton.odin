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

// caller owns the result
simulate_dfa :: proc(aut: DFA, input: []u8) -> []DFA_Step {
    steps := make([dynamic]DFA_Step)

    current := aut.initial
    append(&steps, DFA_Step{current, 0})
    for symbol, i in input {
        current = aut.transitions[current][symbol]
        append(&steps, DFA_Step{current, i+1})
        if current == -1 do break
    }

    return steps[:]
}

bitmap_to_slice :: proc(bitmap: []bool) -> []int {
    result := make([dynamic]int, 0, len(bitmap))
    for active, i in bitmap {
        if active do append(&result, i)
    }
    return result[:]
}

// caller owns result: delete each step.states, then delete the returned slice
simulate_nfa :: proc(aut: NFA, input: []u8) -> []NFA_Step {
    active := make([]bool, len(aut.states))
    next   := make([]bool, len(aut.states))
    defer delete(active)
    defer delete(next)

    active[aut.initial] = true
    epsilon_closure(aut, active)

    steps := make([dynamic]NFA_Step, 0, len(input) + 1)
    append(&steps, NFA_Step{bitmap_to_slice(active), 0})

    for symbol, i in input {
        for j in 0..<len(next) do next[j] = false

        for state in 0..<len(aut.states) {
            if !active[state] do continue
            for to in aut.transitions[state][symbol] {
                next[to] = true
            }
        }
        active, next = next, active
        epsilon_closure(aut, active)
        append(&steps, NFA_Step{bitmap_to_slice(active), i + 1})
    }

    return steps[:]
}

simulate :: proc { simulate_dfa, simulate_nfa }
