// tracker.js
// const fs = require('fs');
// const path = require('path');
// const chokidar = require('chokidar');

import fs from 'fs';
import path from 'path';
import chokidar from 'chokidar';

const workspaceRoot = process.cwd();
const trackingDir = path.join(workspaceRoot, '.modify_tracking');
const modifiedFile = path.join(trackingDir, 'modified.json');
const ignoreFile = path.join(workspaceRoot, '.modify_track_ignore');
const gitignorePath = path.join(trackingDir, '.gitignore');

if (!fs.existsSync(trackingDir)) fs.mkdirSync(trackingDir);
if (!fs.existsSync(modifiedFile)) fs.writeFileSync(modifiedFile, '[]');
if (!fs.existsSync(gitignorePath)) fs.writeFileSync(gitignorePath, '*\n');

let modifiedList = new Set(JSON.parse(fs.readFileSync(modifiedFile, 'utf8')));
const ignoreList = fs.existsSync(ignoreFile)
  ? fs.readFileSync(ignoreFile, 'utf8').split('\n').filter(Boolean)
  : [];

function isIgnored(filePath) {
  return ignoreList.some(ignore => filePath.includes(ignore));
}

function updateModifiedList(filePath) {
  const relPath = '/' + path.relative(workspaceRoot, filePath).replace(/\\/g, '/');
  if (isIgnored(relPath) || relPath.startsWith('/.modify_tracking')) return;

  modifiedList.add(relPath);
  fs.writeFileSync(modifiedFile, JSON.stringify([...modifiedList], null, 2));
}

function removeFromModifiedList(filePath) {
  const relPath = '/' + path.relative(workspaceRoot, filePath).replace(/\\/g, '/');
  if (modifiedList.has(relPath)) {
    modifiedList.delete(relPath);
    fs.writeFileSync(modifiedFile, JSON.stringify([...modifiedList], null, 2));
  }
}

const watcher = chokidar.watch(workspaceRoot, {
  ignored: /(^|[/\\])\../, // ignore dotfiles by default
  ignoreInitial: true,
  persistent: true
});

watcher
  .on('add', updateModifiedList)
  .on('change', updateModifiedList)
  .on('unlink', removeFromModifiedList);

console.log('Tracking file changes in:', workspaceRoot);
