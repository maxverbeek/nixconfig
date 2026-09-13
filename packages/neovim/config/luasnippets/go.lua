return {

  -- For loop
  s(
    "forr",
    fmt(
      [[
        for {} := range {} {{
            {}
        }}
    ]],
      { i(1, "i"), i(2, "slice"), i(3, "// TODO") }
    )
  ),

  -- Error handling
  s(
    "rerr",
    fmt(
      [[
        if err != nil {{
            {}
        }}
    ]],
      { i(1, "return err") }
    )
  ),

  -- Error check
  s(
    "mferr",
    fmt(
      [[
        {}, err := {}
        if err != nil {{
            {}
        }}
    ]],
      { i(1, "value"), i(2, "source"), i(3, "return err") }
    )
  ),

  -- One-line error check
  s(
    "iferr",
    fmt(
      [[
        if {}, err := {}; err != nil {{
            {}
        }}
    ]],
      {
        i(1, "value"),
        i(2, "source"),
        i(3, "return err"),
      }
    )
  ),

  -- Ok check
  s(
    "mfok",
    fmt(
      [[
        {}, ok := {}
        if !ok {{
            {}
        }}
    ]],
      { i(1, "value"), i(2, "source"), i(3, "// TODO") }
    )
  ),

  -- One-line ok check
  s(
    "ifok",
    fmt(
      [[
        if {}, ok := {}; ok {{
            {}
        }}
    ]],
      {
        i(1, "value"),
        i(2, "source"),
        i(3, "// TODO"),
      }
    )
  ),
}
