Byte = Integer
Block = Array

def generate_random_key(length = 16)
  key = Array.new(length) { rand(0..255) }
  key
end

def generate_random_iv
  iv = Array.new(4) { Array.new(4) { rand(0..255) } }
  iv
end

def print_key(key)
  print "Ключ: "
  key.each { |b| print "%02x " % b }
  puts
end

def print_block(block, title = "")
  puts title unless title.empty?
  block.each do |row|
    row.each { |b| print "%02x " % b }
    puts
  end
end

def text_to_blocks(text)
  padded = text.dup
  while padded.size % 16 != 0
    padded += ' '
  end

  blocks = []
  (0...padded.size).step(16) do |i|
    block = Array.new(4) { Array.new(4, 0) }
    (0..3).each do |col|
      (0..3).each do |row|
        block[row][col] = padded[i + col * 4 + row].ord rescue 32
      end
    end
    blocks << block
  end
  blocks
end

def blocks_to_text(blocks)
  text = ""
  blocks.each do |block|
    (0..3).each do |col|
      (0..3).each do |row|
        text += block[row][col].chr
      end
    end
  end

  unless text.empty?
    pad = text[-1].ord
    if pad > 0 && pad <= 16 && text.size >= pad
      valid = true
      (0...pad).each do |i|
        if text[text.size - 1 - i].ord != pad
          valid = false
          break
        end
      end
      text = text[0...-pad] if valid
    end
  end

  text
end

SBOX = [
  0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
  0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
  0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
  0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
  0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
  0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
  0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
  0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
  0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
  0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
  0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
  0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
  0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
  0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
  0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
  0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
].freeze

INV_SBOX = [
  0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
  0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
  0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
  0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
  0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
  0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
  0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
  0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
  0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
  0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
  0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
  0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
  0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
  0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
  0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
  0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
].freeze

RCON = [
  0x00, 0x01, 0x02, 0x04, 0x08,
  0x10, 0x20, 0x40, 0x80, 0x1B, 0x36
].freeze

def expand_key(key)
  expanded_key = Array.new(176, 0)
  (0...16).each { |i| expanded_key[i] = key[i] }

  bytes_generated = 16
  rcon_index = 1
  temp = Array.new(4, 0)

  while bytes_generated < 176
    (0...4).each { |i| temp[i] = expanded_key[bytes_generated - 4 + i] }

    if bytes_generated % 16 == 0
      t = temp[0]
      temp[0] = temp[1]
      temp[1] = temp[2]
      temp[2] = temp[3]
      temp[3] = t

      (0...4).each { |i| temp[i] = SBOX[temp[i]] }

      temp[0] ^= RCON[rcon_index]
      rcon_index += 1
    end

    (0...4).each do |i|
      expanded_key[bytes_generated] = expanded_key[bytes_generated - 16] ^ temp[i]
      bytes_generated += 1
    end
  end

  round_keys = []
  (0...11).each do |i|
    block = Array.new(4) { Array.new(4, 0) }
    (0...16).each do |j|
      block[j % 4][j / 4] = expanded_key[i * 16 + j]
    end
    round_keys << block
  end
  round_keys
end

def xor_blocks(a, b)
  result = Array.new(4) { Array.new(4, 0) }
  (0...4).each do |i|
    (0...4).each do |j|
      result[i][j] = a[i][j] ^ b[i][j]
    end
  end
  result
end

def gmul(a, b)
  p = 0
  hi_bit_set = 0
  (0...8).each do |i|
    p ^= a if b & 1 == 1
    hi_bit_set = a & 0x80
    a <<= 1
    a ^= 0x1b if hi_bit_set == 0x80
    b >>= 1
  end
  p & 0xff
end

def sub_bytes(state)
  (0...4).each do |i|
    (0...4).each do |j|
      state[i][j] = SBOX[state[i][j]]
    end
  end
end

def shift_rows(state)
  temp = state.map(&:dup)
  (1...4).each do |i|
    (0...4).each do |j|
      state[i][j] = temp[i][(j + i) % 4]
    end
  end
end

def mix_columns(state)
  (0...4).each do |col|
    s0 = state[0][col]
    s1 = state[1][col]
    s2 = state[2][col]
    s3 = state[3][col]
    state[0][col] = gmul(s0, 2) ^ gmul(s1, 3) ^ s2 ^ s3
    state[1][col] = s0 ^ gmul(s1, 2) ^ gmul(s2, 3) ^ s3
    state[2][col] = s0 ^ s1 ^ gmul(s2, 2) ^ gmul(s3, 3)
    state[3][col] = gmul(s0, 3) ^ s1 ^ s2 ^ gmul(s3, 2)
  end
end

def encrypt_block(input, round_keys)
  puts "\nНачало шифрования блока:"
  print_block(input, "Исходный блок:")

  state = xor_blocks(input, round_keys[0])
  print_block(state, "После AddRoundKey (раунд 0):")

  (1...10).each do |round|
    sub_bytes(state)
    print_block(state, "После SubBytes (раунд #{round}):")

    shift_rows(state)
    print_block(state, "После ShiftRows (раунд #{round}):")

    mix_columns(state)
    print_block(state, "После MixColumns (раунд #{round}):")

    state = xor_blocks(state, round_keys[round])
    print_block(state, "После AddRoundKey (раунд #{round}):")
  end

  sub_bytes(state)
  print_block(state, "После SubBytes (раунд 10):")

  shift_rows(state)
  print_block(state, "После ShiftRows (раунд 10):")

  state = xor_blocks(state, round_keys[10])
  print_block(state, "После AddRoundKey (раунд 10):")

  puts "Конец шифрования блока"
  state
end

def inv_sub_bytes(state)
  (0...4).each do |i|
    (0...4).each do |j|
      state[i][j] = INV_SBOX[state[i][j]]
    end
  end
end

def inv_shift_rows(state)
  temp = state.map(&:dup)
  (1...4).each do |i|
    (0...4).each do |j|
      state[i][j] = temp[i][(j - i + 4) % 4]
    end
  end
end

def inv_mix_columns(state)
  (0...4).each do |col|
    s0 = state[0][col]
    s1 = state[1][col]
    s2 = state[2][col]
    s3 = state[3][col]
    state[0][col] = gmul(s0, 0x0e) ^ gmul(s1, 0x0b) ^ gmul(s2, 0x0d) ^ gmul(s3, 0x09)
    state[1][col] = gmul(s0, 0x09) ^ gmul(s1, 0x0e) ^ gmul(s2, 0x0b) ^ gmul(s3, 0x0d)
    state[2][col] = gmul(s0, 0x0d) ^ gmul(s1, 0x09) ^ gmul(s2, 0x0e) ^ gmul(s3, 0x0b)
    state[3][col] = gmul(s0, 0x0b) ^ gmul(s1, 0x0d) ^ gmul(s2, 0x09) ^ gmul(s3, 0x0e)
  end
end

def decrypt_block(input, round_keys)
  puts "\nНачало дешифрования блока:"
  print_block(input, "Зашифрованный блок:")

  state = xor_blocks(input, round_keys[10])
  print_block(state, "После AddRoundKey (раунд 10):")

  9.downto(1) do |round|
    inv_shift_rows(state)
    print_block(state, "После InvShiftRows (раунд #{round}):")

    inv_sub_bytes(state)
    print_block(state, "После InvSubBytes (раунд #{round}):")

    state = xor_blocks(state, round_keys[round])
    print_block(state, "После AddRoundKey (раунд #{round}):")

    inv_mix_columns(state)
    print_block(state, "После InvMixColumns (раунд #{round}):")
  end

  inv_shift_rows(state)
  print_block(state, "После InvShiftRows (раунд 0):")

  inv_sub_bytes(state)
  print_block(state, "После InvSubBytes (раунд 0):")

  state = xor_blocks(state, round_keys[0])
  print_block(state, "После AddRoundKey (раунд 0):")

  puts "Конец дешифрования блока"
  state
end

def aes_cbc_encrypt(plaintext_blocks, round_keys, iv)
  ciphertext_blocks = []
  previous = iv.dup

  plaintext_blocks.each_with_index do |block, i|
    puts "\nШифрование блока #{i + 1} из #{plaintext_blocks.size}"
    print_block(previous, "Вектор инициализации (IV) для этого блока:")

    xored = xor_blocks(block, previous)
    print_block(xored, "После XOR с IV:")

    encrypted = encrypt_block(xored, round_keys)
    ciphertext_blocks << encrypted
    previous = encrypted.map(&:dup)
  end
  ciphertext_blocks
end

def aes_cbc_decrypt(ciphertext_blocks, round_keys, iv)
  decrypted_blocks = []
  previous = iv.dup

  ciphertext_blocks.each_with_index do |block, i|
    puts "\nДешифрование блока #{i + 1} из #{ciphertext_blocks.size}"
    print_block(previous, "Вектор инициализации (IV) для этого блока:")

    decrypted = decrypt_block(block, round_keys)
    plain = xor_blocks(decrypted, previous)
    decrypted_blocks << plain
    previous = block.map(&:dup)

    print_block(plain, "После XOR с IV:")
  end
  decrypted_blocks
end

def main
  puts "Введите текст для шифрования:"
  input_text = gets.chomp

  master_key = generate_random_key
  iv = generate_random_iv

  puts "\nГенерация ключей и вектора инициализации"
  puts "========================================"
  print_key(master_key)
  print_block(iv, "\nВектор инициализации:")

  plaintext_blocks = text_to_blocks(input_text)

  puts "\nПреобразование текста в блоки"
  puts "============================="
  plaintext_blocks.each_with_index do |block, i|
    print_block(block, "Блок текста #{i + 1}:")
  end

  round_keys = expand_key(master_key)

  puts "\nРаундовые ключи"
  puts "==============="
  round_keys.each_with_index do |key, i|
    print_block(key, "Раундовый ключ #{i}:")
  end

  puts "\nПроцесс шифрования (AES-CBC)"
  puts "============================"
  ciphertext_blocks = aes_cbc_encrypt(plaintext_blocks, round_keys, iv)

  ciphertext_str = ciphertext_blocks.each_with_object("") do |block, str|
    (0...4).each do |col|
      (0...4).each do |row|
        str << block[row][col].chr
      end
    end
  end

  puts "\nРезультаты шифрования"
  puts "====================="
  ciphertext_blocks.each_with_index do |block, i|
    print_block(block, "Зашифрованный блок #{i + 1}:")
  end

  puts "\nПроцесс дешифрования (AES-CBC)"
  puts "=============================="
  decrypted_blocks = aes_cbc_decrypt(ciphertext_blocks, round_keys, iv)
  decrypted_text = blocks_to_text(decrypted_blocks)

  decrypted_text = decrypted_text.rstrip

  puts "\nРезультаты дешифрования"
  puts "======================="
  decrypted_blocks.each_with_index do |block, i|
    print_block(block, "Дешифрованный блок #{i + 1}:")
  end

  puts "\nИсходный текст:"
  puts input_text
  puts "\nРасшифрованный текст:"
  puts decrypted_text

  puts "Зашифрованный текст:"
  ciphertext_str.each_byte { |c| print "%02x " % c }
  puts
end

main
