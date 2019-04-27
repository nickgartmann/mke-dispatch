import { Config } from '@stencil/core';

export const config: Config = {
  namespace: 'components',
  globalStyle: 'src/globals/app.css',
  copy: [
    { src: '../vendor', dest: '../vendor' }
  ],
  outputTargets:[
    { 
      type: 'dist',
      dir: '../priv/static/mpd'
    }
  ]
};
