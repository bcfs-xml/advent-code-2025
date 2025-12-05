# Módulo principal
defmodule SafePassword do
  # Função principal que resolve o problema
  def solve(input) do
    rotations = input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))

    # Chama a função que processa as rotações
    # começando na posição 50
    process_rotations(rotations, 50, 0)
  end

  # Função que processa cada rotação
  # Caso base: quando não há mais rotações, retorna o contador
  defp process_rotations([], _current_position, zero_count) do
    zero_count
  end

  # processa uma rotação e continua com o resto
  defp process_rotations([rotation | rest], current_position, zero_count) do
    direction = String.at(rotation, 0)
    distance = rotation |> String.slice(1..-1//1) |> String.to_integer()

    # Calcula a nova posição baseado na direção
    new_position = case direction do
      # L = Left (esquerda) = subtrair e fazer módulo 100
      "L" -> rem(current_position - distance + 100, 100)

      # R = Right (direita) = adicionar e fazer módulo 100
      "R" -> rem(current_position + distance, 100)
    end

    # Atualiza o contador se a nova posição for 0
    # if/else incrementa zero_count quando new_position == 0
    new_zero_count = if new_position == 0 do
      zero_count + 1
    else
      zero_count
    end

    # Chamada recursiva com o resto das rotações
    # a nova posição e o contador atualizado
    process_rotations(rest, new_position, new_zero_count)
  end
end

# Exemplo de teste
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

# Testa com o exemplo (deve retornar 3)
IO.puts("=== Testando com exemplo ===")
result = SafePassword.solve(example_input)
IO.puts("Resultado do exemplo: #{result}")
IO.puts("Esperado: 3")
IO.puts("")

# Lê o input real do arquivo pluzze_input_part01.txt
IO.puts("=== Solução do puzzle ===")

# Verifica se o arquivo pluzze_input_part01.txt existe
# File.exists?/1 retorna true se o arquivo existir
if File.exists?("pluzze_input_part01.txt") do
  # Lê o conteúdo do arquivo
  real_input = File.read!("pluzze_input_part01.txt")

  # Resolve o puzzle com o input real
  password = SafePassword.solve(real_input)
  IO.puts("A senha é: #{password}")
else
  # Mensagem de erro se o arquivo não existir
  IO.puts("ERRO: Arquivo pluzze_input_part01.txt não encontrado!")
end
