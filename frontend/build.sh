#!/bin/bash

main() {
  process_id=$(pm2 id valuecell)
  
  if [ $process_id == "[]" ]; then
    echo "Process valuecell not found"
  else
    echo ">>>>>>>> stop and delete valuecell"
    pm2 delete valuecell
  fi

  echo ">>>>>>>> node version is " && node -v

  npm i pm2 -g
  npm i vite -g

  rm -rf /usr/local/lighthouse/www/valuecell

  mkdir -p /usr/local/lighthouse/www/valuecell

  echo "Starting frontend dev server (bun run dev)..."

  echo ">>>>>>>> start install ..."
  bun install

  echo ">>>>>>>> start build ..."
  bun run build

  echo ">>>>>>>> start cp files ..."
  cp -r build /usr/local/lighthouse/www/valuecell/build
  cp package.json /usr/local/lighthouse/www/valuecell

  echo ">>>>>>>> start deploy ..."
  cd "/usr/local/lighthouse/www/valuecell"
  npm run deploy
}

main "$@"