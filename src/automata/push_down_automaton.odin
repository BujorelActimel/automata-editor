package automata;

PDA_Accept_Mode :: enum { Final_State, Empty_Stack }

PDA_Transition :: struct {
    from:       int,
    to:         int,
    symbol:     Maybe(u8), // nil = epsilon
    stack_top:  u8,        // stack symbol consumed
    stack_push: []u8,      // symbols pushed, empty slice = epsilon (just pop)
}

PDA :: struct {
    states:         []string,
    alphabet:       []u8,
    stack_alphabet: []u8,
    transitions:    []PDA_Transition,
    initial:        int,
    initial_stack:  u8,
    accepting:      []bool,
    accept_mode:    PDA_Accept_Mode,
}
