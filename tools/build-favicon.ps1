Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path $PSScriptRoot '..\designs\favicon escolhido corrigido.png'
$outputRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sizes = @(16, 32, 48, 64)
$source = [System.Drawing.Image]::FromFile($sourcePath)
$pngFrames = @()

try {
    foreach ($size in $sizes) {
        if ($false) {
            $masterSize = 256
            $master = [System.Drawing.Bitmap]::new($masterSize, $masterSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $masterGraphics = [System.Drawing.Graphics]::FromImage($master)
            try {
                $masterGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                $masterGraphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
                $masterGraphics.Clear([System.Drawing.Color]::FromArgb(255, 17, 39, 29))
                $font = [System.Drawing.Font]::new('Bodoni MT', 205, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
                $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 220, 174, 82))
                $format = [System.Drawing.StringFormat]::GenericTypographic
                try {
                    $bounds = $masterGraphics.MeasureString('&', $font, 1000, $format)
                    $x = ($masterSize - $bounds.Width) / 2
                    $y = ($masterSize - $bounds.Height) / 2 - 5
                    $masterGraphics.DrawString('&', $font, $brush, $x, $y, $format)
                }
                finally {
                    $font.Dispose()
                    $brush.Dispose()
                }
            }
            finally {
                $masterGraphics.Dispose()
            }

            $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage($master, 0, 0, $size, $size)
            }
            finally {
                $graphics.Dispose()
                $master.Dispose()
            }
        }
        else {
        $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.DrawImage($source, 0, 0, $size, $size)
        }
        finally {
            $graphics.Dispose()
        }
        }

        $pngPath = Join-Path $outputRoot ("favicon-{0}x{0}.png" -f $size)
        $bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)

        $stream = [System.IO.MemoryStream]::new()
        $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngFrames += ,$stream.ToArray()
        $stream.Dispose()
        $bitmap.Dispose()
    }
}
finally {
    $source.Dispose()
}

$icoPath = Join-Path $outputRoot 'favicon.ico'
$file = [System.IO.File]::Open($icoPath, [System.IO.FileMode]::Create)
$writer = [System.IO.BinaryWriter]::new($file)
try {
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$sizes.Count)

    $offset = 6 + (16 * $sizes.Count)
    for ($index = 0; $index -lt $sizes.Count; $index++) {
        $size = $sizes[$index]
        $writer.Write([byte]$size)
        $writer.Write([byte]$size)
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$pngFrames[$index].Length)
        $writer.Write([uint32]$offset)
        $offset += $pngFrames[$index].Length
    }

    foreach ($frame in $pngFrames) {
        $writer.Write($frame)
    }
}
finally {
    $writer.Dispose()
    $file.Dispose()
}
