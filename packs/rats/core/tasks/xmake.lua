------ Use taskflow and provide unified taskflow places (such as InitFlow)

add_rules("mode.debug", "mode.release")

local ns = NS.use();

--[[ yaml
third-party:
    name: taskflow
    source: https://github.com/taskflow/taskflow
    project: https://taskflow.github.io/
    authors:
        - "Tsung-Wei Huang (https://orcid.org/0000-0001-9768-3378)"
        - "Dian-Lun Lin"
        - "Chun-Xun Lin"
        - "Yibo Lin (https://orcid.org/0000-0002-0977-2774)"
    license: MIT License Derivative (https://github.com/taskflow/taskflow/blob/master/LICENSE)
    references:
        - |
            T.-W. Huang, D.-L. Lin, C.-X. Lin, and Y Lin, "Taskflow: A Lightweight Parallel and
            Heterogeneous Task Graph Computing System," IEEE Transactions on Parallel and
            Distributed Systems (TPDS), vol. 33, no. 6, pp. 1303-1320, June 2022.
    reasoning: |
        Handy and elegant library for creating a graph of tasks avoiding ambivalence of event
        ordering of independently developed components which need to cooperate. It also helps with
        parallel programming.
]]
add_requires("taskflow v3.7.0")

Rats.target_cpp(ns)
    add_packages("taskflow", {public = true})
    add_deps(ns:full("base"))