function Run()
  if (vim.o.filetype == "") then
    vim.o.filetype = 'sh'
    io.popen("sudo chmod +x " .. vim.fn.expand('%'))
    if vim.fn.getline(1) ~= '#!/usr/bin/env bash' then
      vim.cmd("1s~^~#!/usr/bin/env bash\r\r")
      vim.fn.setreg("/", "")
    end
  elseif (vim.o.filetype == "html") then
    vim.ui.open(vim.fn.expand('%'))
  end
end
