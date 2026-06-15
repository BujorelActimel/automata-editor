# automata-editor

An educational tool for exploring formal language theory concepts from [UBB](https://www.cs.ubbcluj.ro/)'s LFTC course. (Formal Languages and Compiler Design)

The core engine is written in [Odin](https://odin-lang.org/) and compiled to WebAssembly, with a web frontend for visualization.

## Automata supported

- Deterministic Finite Automaton (DFA)
- Non-deterministic Finite Automaton (NFA / NFA-ε)
- Pushdown Automaton (PDA)
- Turing Machine (TM)

## Planned features

- Visual automaton editor
- Step-by-step simulation traces
- Automatic classification (DFA / NFA / NFA-ε detection)
- NFA → DFA conversion (subset construction)
- DFA minimization (Hopcroft's algorithm)
- ε-NFA → NFA conversion (ε-closure elimination)
- Grammar → automaton conversion
- Parsing visualizations
