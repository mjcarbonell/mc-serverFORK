const express = require('express');
const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

const app = express();
const PORT = process.env.PORT || 3000;

// Endpoint to download /WorldBackup volume contents
app.get('/download-backup', (req, res) => {
  const volumePath = '/WorldBackup';  // Adjust the path
  const archivePath = path.join(__dirname, 'world-backup.zip');
  
  // Create a zip file and stream it
  const output = fs.createWriteStream(archivePath);
  const archive = archiver('zip', {
    zlib: { level: 9 }  // Compression level
  });

  output.on('close', function() {
    console.log(archive.pointer() + ' total bytes');
    console.log('WorldBackup has been archived.');
    
    // Send the file to the client for download
    res.download(archivePath, 'world-backup.zip', function(err) {
      if (err) {
        console.error(err);
      } else {
        // Optionally delete the archive after sending
        fs.unlinkSync(archivePath);
      }
    });
  });

  // Catch any errors
  archive.on('error', function(err) {
    throw err;
  });

  // Pipe archive data to the file
  archive.pipe(output);

  // Append files from the volume directory
  archive.directory(volumePath, false);

  // Finalize the archive
  archive.finalize();
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
