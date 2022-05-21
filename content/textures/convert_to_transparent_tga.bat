for /R %%f in (*.bmp) do magick "%%f" -transparent #ff00ff "%%~nf.tga"
pause