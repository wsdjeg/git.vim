local M = {}
local logger
function M.info(msg)
  if not logger then
    pcall(function()
      logger = require('logger').derive('flygrep')
      logger.info(msg)
    end)
  else
    logger.info(msg)
  end
end
function M.warn(msg)
  if not logger then
    pcall(function()
      logger = require('logger').derive('flygrep')
      logger.warn(msg)
    end)
  else
    logger.warn(msg)
  end
end
function M.debug(msg)
  if not logger then
    pcall(function()
      logger = require('logger').derive('flygrep')
      logger.debug(msg)
    end)
  else
    logger.debug(msg)
  end
end

return M
