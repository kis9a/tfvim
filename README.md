### Required

- <https://github.com/BurntSushi/ripgrep>

### Commands

- TerraformJumpDefinition
- TerraformReferences
- TFRef

### Installation

```vim
Plug 'kis9a/tfvim'
```

### Example

```
autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sd :TerraformJumpDefinition<CR>
autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sh :TerraformReferences<CR>
autocmd BufNewFile,BufReadPost *.tf nnoremap <silent> sr :TFRef<CR>
```
