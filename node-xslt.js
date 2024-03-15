const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require('fs/promises');
const path = require('path');

async function processDataWithDocker(teiDirectory, outputFormat) {
    try {
        // Create a symbolic link to the data directory
        const { stdout: linkOutput } = await exec(`sudo docker run --rm cudl-xslt:0.0.4 ln -s ${teiDirectory} data`);
        console.log('Symbolic link created:', linkOutput.trim());

        // Run the ant build command inside the Docker container
        const { stdout: antOutput } = await exec(`sudo docker run --rm cudl-xslt:0.0.4 ant -buildfile ./bin/build.xml "${outputFormat}"`);
        console.log('Ant command executed:', antOutput.trim());

        // Remove the data directory in the Docker container
        const { stdout: removeOutput } = await exec('sudo docker run --rm cudl-xslt:0.0.4 rm -r data');
        console.log('Data directory removed:', removeOutput.trim());

        // Read and parse JSON files
        const jsonDir = path.join(__dirname, 'json');
        console.log('JSON directory:', jsonDir);
        const files = await fs.readdir(jsonDir);

        const jsonData = await Promise.all(files.map(async (file) => {
            const filePath = path.join(jsonDir, file);
            const stats = await fs.stat(filePath);
            if (stats.isDirectory()) {
                const dirFiles = await fs.readdir(filePath);
                if (dirFiles.some((dirFile) => dirFile.endsWith('.json'))) {
                    return readJsonFiles(path.join(filePath, dirFiles.find((dirFile) => dirFile.endsWith('.json'))));
                }
            } else if (file.endsWith('.json')) {
                return readJsonFiles(filePath);
            }
        }));

        // Filter out undefined values (directories without .json files)
        return jsonData.filter((data) => data);
    } catch (err) {
        console.error('Error:', err);
        return [];
    }
}

async function readJsonFiles(filePath) {
    try {
        const jsonData = await fs.readFile(filePath, 'utf8');
        return JSON.parse(jsonData);
    } catch (err) {
        console.error('Error reading JSON file:', err);
        return null;
    }
}

// Example usage
processDataWithDocker('dl-data-samples/source-data/data/items/data/tei/MS-TEST-ITEM-00001/', 'json')
    .then((jsonData) => {
        console.log('JSON data:', jsonData);
    })
    .catch((err) => {
        console.error('Error:', err);
    });
