# Módulo principal
defmodule SafePasswordPart2 do
  # Função principal que resolve o problema
  def solve(input) do
    # Divide o input em linhas e remove linhas vazias
    rotations = input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))

    # Chama a função que processa as rotações
    process_rotations(rotations, 50, 0)
  end

  # Função que processa cada rotação
  defp process_rotations([], _current_position, zero_count) do
    zero_count
  end

  # processa uma rotação e continua com o resto
  defp process_rotations([rotation | rest], current_position, zero_count) do

    direction = String.at(rotation, 0)
    distance = rotation |> String.slice(1..-1//1) |> String.to_integer()

    # Calcula quantas vezes passa 0 DURANTE a rotação

    {new_position, zeros_during_rotation} = case direction do
      # L = Left (esquerda) = subtrair
      "L" -> count_zeros_during_rotation(current_position, -distance)

      # R = Right (direita) = adicionar
      "R" -> count_zeros_during_rotation(current_position, distance)
    end

    new_zero_count = zero_count + zeros_during_rotation

    process_rotations(rest, new_position, new_zero_count)
  end

  # Retorna uma tupla {posição_final, quantidade_de_zeros}
  defp count_zeros_during_rotation(start_position, distance) do
    # Normaliza start_position para estar sempre entre 0 e 99
    start_position = rem(rem(start_position, 100) + 100, 100)

    # Calcula a posição final
    final_position = rem(rem(start_position + distance, 100) + 100, 100)

    # Conta quantos zeros encontramos durante o movimento

    zero_count = count_zeros_in_range(start_position, distance)

    # Retorna a posição final e o total de zeros encontrados
    {final_position, zero_count}
  end

  defp count_zeros_in_range(start, distance) when distance == 0 do
    0
  end

  defp count_zeros_in_range(start, distance) when distance > 0 do
    if distance >= (100 - start) do
      remaining_after_first_zero = distance - (100 - start)
      additional_zeros = div(remaining_after_first_zero, 100)
      1 + additional_zeros
    else
      0
    end
  end

  defp count_zeros_in_range(start, distance) when distance < 0 do
    abs_distance = abs(distance)


    if abs_distance >= start do
      remaining_after_first_zero = abs_distance - start
      additional_zeros = div(remaining_after_first_zero, 100)

      if start == 0 do
        div(abs_distance, 100)
      else
        1 + additional_zeros
      end
    else
      0
    end
  end
end

# Exemplo do part02.md para testar
example_input = """
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
"""

# Testa com o exemplo (deve retornar 6)
IO.puts("=== Testando com exemplo da Part 2 ===")
result = SafePasswordPart2.solve(example_input)
IO.puts("Resultado do exemplo: #{result}")
IO.puts("Esperado: 6")
IO.puts("")

# Lê o input real do arquivo pluzze_input_part02.txt
IO.puts("=== Solução do puzzle Part 2 ===")

if File.exists?("pluzze_input_part02.txt") do
  # Lê o conteúdo do arquivo
  real_input = File.read!("pluzze_input_part02.txt")

  password = SafePasswordPart2.solve(real_input)
  IO.puts("A senha da Part 2 é: #{password}")
else
  IO.puts("ERRO: Arquivo pluzze_input_part02.txt não encontrado!")
end
