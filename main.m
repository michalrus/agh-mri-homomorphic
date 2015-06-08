(* ::Package:: *)

(* read config *)
configRaw=ReadString["./config"];
ToExpression[StringReplace[StringCases[configRaw, RegularExpression["(^|\\s)\\S+\\s*=\\s*[\\d.]+"]], {"_"->""}]];
ToExpression[StringReplace[StringCases[configRaw, RegularExpression["(^|\\s)\\S+\\s*=\\s*'.*?'"]],   {"_"->"", "'"->"\""}]];
