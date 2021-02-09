defmodule Practice.Calc do
  def parse_float(text) do
    {num, _} = Float.parse(text)
    num
  end

  def tag(token) do
    case token do
      "*" -> {:op, 3, token}
      "/" -> {:op, 3, token}
      "+" -> {:op, 2, token}
      "-" -> {:op, 2, token}
      _ -> {:number, token}
    end
  end

  # These functions implement Dykstras shunting yard algorithm
  # Algorithm Details: https://en.wikipedia.org/wiki/Shunting-yard_algorithm

  # Push an operator onto the operator stack 
  def push_operator(precedence, op, output, []) do
    {output, [{precedence, op}]}
  end

  def push_operator(precedence, op, output, operators) do
    {head_prec, head_token} = hd operators
    if precedence > head_prec do
      {output, [{precedence, op} | operators]}
    else
      push_operator(precedence, op, [head_token | output], tl(operators))
    end
  end

  # Pop operators off the operator stack since we have reached the end
  # of the expression
  def pop_operators(output, []) do
    output
  end

  def pop_operators(output, [head | tail]) do
    {_prec, op} = head
    pop_operators([op | output], tail)
  end

  # Implement the shunting yard algorithm to transform an expression
  # from infix notation to postfix notation. 
  def shunting_yard([], output, operators) do
    pop_operators(output, operators)
  end

  def shunting_yard(tokens, output, operators) do
    case hd tokens do
      {:op, precedence, op} -> 
        {new_output, new_operators} = push_operator(precedence, op, output, operators)
        shunting_yard(tl(tokens), new_output, new_operators)
      {:number, n} -> shunting_yard(tl(tokens), [n | output], operators)
    end
  end


  def evaluate([], stack) do
    hd(stack)
  end

  def evaluate([head | tail], stack) do
    case head do
      "*" -> 
        {right, stack} = List.pop_at(stack, 0)
        {left, stack} = List.pop_at(stack, 0)
        evaluate(tail, [(left * right) | stack])
      "/" -> 
        {right, stack} = List.pop_at(stack, 0)
        {left, stack} = List.pop_at(stack, 0)
        evaluate(tail, [(left / right) | stack])
      "+" -> 
        {right, stack} = List.pop_at(stack, 0)
        {left, stack} = List.pop_at(stack, 0)
        evaluate(tail, [(left + right) | stack])
      "-" -> 
        {right, stack} = List.pop_at(stack, 0)
        {left, stack} = List.pop_at(stack, 0)
        evaluate(tail, [(left - right) | stack])
      _ -> evaluate(tail, [ parse_float(head) | stack])
    end
  end

  def evaluate([head | tail]) do
    evaluate(tail, [parse_float(head)])
  end


  def calc(expr) do
    # This should handle +,-,*,/ with order of operations,
    # but doesn't need to handle parens.
    expr
    |> String.split(~r/\s+/)
    |> Enum.map(&tag/1)
    |> shunting_yard([], [])
    |> Enum.reverse # In postfix notation, since our enqueue was to the head for performance
    |> evaluate

    # Hint:
    # expr
    # |> split
    # |> tag_tokens  (e.g. [+, 1] => [{:op, "+"}, {:num, 1.0}]
    # |> convert to postfix
    # |> reverse to prefix
    # |> evaluate as a stack calculator using pattern matching
  end
end
