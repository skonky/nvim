(fn set-opt [opt value action]
  (if (= action :append)
      ((. vim.opt opt :append) value)
      (tset vim.opt opt value)))

(fn set-opts [opts]
  (each [k v (pairs opts)]
    (set-opt k v)))

(fn set-globals [globals]
  (each [k v (pairs globals)]
    (tset vim.g k v)))

(fn set-keymap [mode lhs rhs opts]
  (vim.keymap.set mode lhs rhs (or opts {})))

{: set-opts : set-opt : set-globals : set-keymap}
