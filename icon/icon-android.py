import os
from PIL import Image

image = Image.open('Logo.png')

imagex72 = image.resize((72,72))
imagex48 = image.resize((48,48))
imagex96 = image.resize((96,96))
imagex144 = image.resize((144,144))
imagex192 = image.resize((192,192))

imagex72.save(os.path.dirname(os.getcwd()) + '\\android\\app\\src\\main\\res\\mipmap-hdpi\\' + 'logo.png')
imagex48.save(os.path.dirname(os.getcwd()) + '\\android\\app\\src\\main\\res\\mipmap-mdpi\\' + 'logo.png')
imagex96.save(os.path.dirname(os.getcwd()) + '\\android\\app\\src\\main\\res\\mipmap-xhdpi\\' + 'logo.png')
imagex144.save(os.path.dirname(os.getcwd()) + '\\android\\app\\src\\main\\res\\mipmap-xxhdpi\\' + 'logo.png')
imagex192.save(os.path.dirname(os.getcwd()) + '\\android\\app\\src\\main\\res\\mipmap-xxxhdpi\\' + 'logo.png')

print("Done.")