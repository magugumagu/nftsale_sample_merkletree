const { rejects } = require('assert');
const fs=require('fs');
const testObj ={
    "name": "SPAMDAO PASS NFT",
    "description": "SPAM DAO PASS is japan nft alpha community PASS",
    "image": "https://ipfs.io/ipfs/QmPpucMwtHscLTfy1Bac7HReT66pf4dwEG3ZkonAmphn4i/2.jpg"
}

const createFile = (pathName, source) => {
    const toJSON =JSON.stringify(source);
    fs.writeFile(pathName,toJSON, (err) => {
        if (err) rej(err);
        if (!err) {
            console.log('JSONファイルを生成しました');
        }
    });
};

let basicimage="https://ipfs.io/ipfs/QmctVnrA52WH2kzUzgSj4zfXvCTWLCVZ58w7yWSNLW35oD"
for (i=1;i<90;i++) {
    let imagei=basicimage+ i + ".jpg"
    let Obj = {
        "name": "SPAMDAO PASS NFT",
    "description": "SPAM DAO PASS is japan nft alpha community PASS",
    "image": basicimage
    }
    let where="./json/" + i + ".json"
    console.log(Obj)
    createFile(where, Obj);
}

//basejsonuri  ;QmNYe6HdtKSbs5khbwfBZCEXJSot8XgVfjjg57yUqDreV7