// eslint-disable-next-line sort-imports
import { defineConfig, type DefaultTheme, type HeadConfig } from 'vitepress'

export default defineConfig({
  lang: 'en-US',
  title: 'Gitpod Enhanced',
  base: '/',
  themeConfig: <DefaultTheme.Config>{
    logo: '/gitpod.svg',
    repo: 'nberlette/gitpod-enhanced',
    nav: [
      {
        text: 'Home',
        link: '/',
      },
      {
        text: 'Gitpod + Docker',
        link: '/gitpod-docker',
      },
      {
        text: 'View on GitHub',
        link: 'https://github.com/nberlette/gitpod-enhanced',
      },
      {
        text: 'Edit in Gitpod',
        link: 'https://gitpod.io/#https://github.com/nberlette/gitpod-enhanced',
      },
    ],
    docsDir: 'docs',
    docsBranch: 'main',
    editLinks: true,
    editLinkText: 'Edit on GitHub',
    lastUpdated: true,
    prevLinks: true,
    nextLinks: true,
  },
  head: <HeadConfig[]>[
    [
      'link',
      {
        rel: 'prefetch',
        as: 'style',
        type: 'text/css;charset=utf-8',
        href: 'https://cdn.jsdelivr.net/npm/@typehaus/metropolis/index.min.css',
        crossorigin: 'anonymous',
      },
    ],
    [
      'link',
      {
        rel: 'stylesheet',
        type: 'text/css;charset=utf-8',
        href: 'https://cdn.jsdelivr.net/npm/@typehaus/metropolis/index.min.css',
        crossorigin: 'anonymous',
      },
    ],
    [
      'link',
      {
        rel: 'prefetch',
        as: 'style',
        type: 'text/css;charset=utf-8',
        href: '/style.css',
      },
    ],
    [
      'link',
      {
        rel: 'stylesheet',
        type: 'text/css;charset=utf-8',
        href: '/style.css',
      },
    ],
    [
      'link',
      {
        rel: 'prefetch',
        as: 'icon',
        type: 'image/svg+xml;charset=utf-8',
        href: '/gitpod.svg',
      },
    ],
    [
      'link',
      {
        rel: 'icon',
        type: 'image/svg+xml;charset=utf-8',
        href: '/gitpod.svg',
      },
    ],
    [
      'link',
      {
        rel: 'mask-icon',
        type: 'image/svg+xml;charset=utf-8',
        href: '/gitpod.svg',
        color: '#ffae33',
      },
    ],
    [
      'meta',
      {
        name: 'theme-color',
        content: '#112233',
        value: '#112233',
      },
    ],
  ],
})
