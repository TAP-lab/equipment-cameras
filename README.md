# Equipment cameras
Files and scripts for TAP lab's equipment monitoring cameras

# Usage
- Upload uploader.php to a webserver
- Change `keys` to an array of secret keys to authenticate the cameras (yes this should be a `.env` but I'll get around to it later)
  
Cameras should POST to `https://example.com/uploader.php` with the following attributes
- `dir`: The camera's name or identifier, this should be unique per endpoint
- `key`: One of the secret keys defined in the `$keys` array
- `image`: The snapshot to save (as a `.jpg`)

The image can be accessed at `https://example.com/{dir_name}/image.jpg`
