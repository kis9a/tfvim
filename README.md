### Required

- <https://github.com/BurntSushi/ripgrep>

### Commands

- TerraformJumpDefinition
- TerraformReferences
- TFRef


### example

```vim
if !empty(glob('~/path/to/tfvim.vim'))
  source ~/path/to/tfvim.vim
endif

autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sd :TerraformJumpDefinition<CR>
autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sh :TerraformReferences<CR>
autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sr :TFRef<CR>
```
