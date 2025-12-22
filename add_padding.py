from PIL import Image

def add_margin(input_path, output_path, margin_ratio):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    # Calcula o novo tamanho (adicionando margem)
    new_width = int(width * (1 + margin_ratio))
    new_height = int(height * (1 + margin_ratio))
    
    # Cria uma nova imagem transparente (ou com a cor de fundo se preferir, mas transparente é melhor para ícone)
    # Usando cor transparente (0,0,0,0)
    new_img = Image.new("RGBA", (new_width, new_height), (0, 0, 0, 0))
    
    # Cola a imagem original no centro
    paste_x = (new_width - width) // 2
    paste_y = (new_height - height) // 2
    new_img.paste(img, (paste_x, paste_y), img)
    
    new_img.save(output_path)
    print(f"Imagem salva em: {output_path}")

# Adiciona 50% de margem (reduzindo o ícone visualmente em relação ao total)
add_margin("assets/icon/bank_icon.png", "assets/icon/bank_icon_padded.png", 0.6)
