package automata

Direction :: enum { Left, Right, Stay }

TM_Transition :: struct {
    from:  int,
    to:    int,
    read:  u8,        // tape symbol read
    write: u8,        // tape symbol written
    dir:   Direction,
}

Turing_Machine :: struct {
    states:         []string,
    input_alphabet: []u8,
    tape_alphabet:  []u8,
    blank:          u8,
    transitions:    []TM_Transition,
    initial:        int,
    accepting:      []bool,
}
