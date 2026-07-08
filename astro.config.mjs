import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';

export default defineConfig({
  site: 'https://pi826.github.io',
  integrations: [mdx()],
  markdown: {
    remarkPlugins: [remarkMath],
    rehypePlugins: [
      [
        rehypeKatex,
        {
          // KaTeX非対応のマクロが必要になった場合はここに追加する
          // 例: macros: { '\\RR': '\\mathbb{R}' }
          macros: {},
        },
      ],
    ],
  },
});
