module Serializer (encodeCommand) where

import Data
import Data.ByteString hiding (concat, pack)
import Data.ByteString.Char8 hiding (concat)

encodeCommand :: BufferID -> SequenceNum -> IdeMessage -> ByteString
encodeCommand bufferID sequenceNumber message = pack commandLine where
    commandLine = buf ++ ":" ++ cmd ++ separator ++ seqno ++ args ++ "\n"
    buf         = show bufferID
    cmd         = messageTypeString message
    seqno       = show sequenceNumber
    args        = encodeMessageArgs message
    separator   = case message of
                    CommandMessage _  -> "!"
                    FunctionMessage _ -> "/"

encodeStringArg :: String -> String
encodeStringArg arg = " \"" ++ arg ++ "\""

encodeIntArg :: Int -> String
encodeIntArg arg = ' ' : show arg

encodeBoolArg :: Bool -> String
encodeBoolArg True  = " T"
encodeBoolArg False = " F"

encodeMessageArgs :: IdeMessage -> String
encodeMessageArgs (CommandMessage m)  = encodeCommandArgs m
encodeMessageArgs (FunctionMessage f) = encodeFunctionArgs f

encodeFunctionArgs :: VimFunctionType -> String
encodeFunctionArgs (GetAnno serNum)  = encodeIntArg serNum
encodeFunctionArgs (Insert off text) = encodeIntArg off ++ encodeStringArg text
encodeFunctionArgs (Remove off len)  = encodeIntArg off ++ encodeIntArg len
encodeFunctionArgs _                 = ""

-- Can this be refactored using Data.Data?
encodeCommandArgs :: VimCommandType -> String
encodeCommandArgs (AddAnno serNum typeNum off len)  = concat
                   [encodeIntArg serNum, encodeIntArg typeNum, encodeIntArg off,
                    encodeIntArg len]
encodeCommandArgs (BalloonResult text)              = encodeStringArg text
encodeCommandArgs (DefineAnnoType typeNum typeName tooltip glyphFile fg bg) =
    concat [encodeIntArg typeNum, encodeStringArg typeName,
                    encodeStringArg tooltip, encodeStringArg glyphFile,
                    encodeStringArg fg, encodeStringArg bg]
encodeCommandArgs (EditFile path)                   = encodeStringArg path
encodeCommandArgs (Guard off len)                   = encodeIntArg off ++ encodeIntArg len
encodeCommandArgs (MoveAnnoToFront serNum)          = encodeIntArg serNum
encodeCommandArgs (NetbeansBuffer isNetbeansBuffer) = encodeBoolArg isNetbeansBuffer
encodeCommandArgs (PutBufferNumber path)            = encodeStringArg path
encodeCommandArgs (RemoveAnno serNum)               = encodeIntArg serNum
encodeCommandArgs (SetBufferNumber path)            = encodeStringArg path
encodeCommandArgs (SetDot off)                      = encodeIntArg off
encodeCommandArgs (SetExitDelay seconds)            = encodeIntArg seconds
encodeCommandArgs (SetFullName pathname)            = encodeStringArg pathname
encodeCommandArgs (SetModified modified)            = encodeBoolArg modified
encodeCommandArgs (SetModTime time)                 = encodeIntArg time
encodeCommandArgs (SetTitle name)                   = encodeStringArg name
encodeCommandArgs (SetVisible visible)              = encodeBoolArg visible
encodeCommandArgs (ShowBalloon text)                = encodeStringArg text
encodeCommandArgs (Unguard off len)                 = encodeIntArg off ++ encodeIntArg len
encodeCommandArgs _ = ""
