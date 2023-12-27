% \RequirePackage{kvoptions}
% \SetupKeyvalOptions{family=sp,prefix=sp@}

% % if true, you will receive debugging information in the log
% \DeclareBoolOption{debug}

% \ProcessKeyvalOptions*

\providecommand\sp@documentclass{
   \PassOptionsToClass{11pt,a4paper,ngerman}{article}
   \LoadClass{article}
}
\sp@documentclass

% load the bare minimum of default packages ==============================
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{babel}

\RequirePackage{microtype}

% page layout ============================================================
\def\sp@geometry@left{2cm}%
\def\sp@geometry@right{2cm}%
\def\sp@geometry@top{1cm}%
\def\sp@geometry@bottom{2cm}%
\providecommand\sp@geometry{
   \PassOptionsToPackage{
      left=\sp@geometry@left,
      right=\sp@geometry@right,
      top=\sp@geometry@top,
      bottom=\sp@geometry@bottom,
      includehead%
   }{geometry}
   \RequirePackage{geometry}
}
\sp@geometry