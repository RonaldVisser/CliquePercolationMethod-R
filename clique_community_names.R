### Clique Percolation Method
### Palla, G., Derényi, I., Farkas, I., & Vicsek, T. (2005). Uncovering the overlapping community structure of complex networks in nature and society. Nature, 435(7043), 814-818.
### Source: https://github.com/angelosalatino/CliquePercolationMethod-R
### adapted to add names (Ronald Visser)
clique_community_names <- function(g, k) {
  require(igraph)
  require(dplyr)
  clq <- cliques(g, min=k, max=k) %>% lapply(as.vector)
  
  # get node names
  node <- (V(g)$name)
  node <- as.data.frame(node)
  node <- node %>% mutate(id = row_number())
    
  #find edges
  edges <- c()
  for (i in seq_along(clq)) {
    for (j in seq_along(clq)) {
      if ( length(unique(c(clq[[i]], clq[[j]]))) == k+1 ) {
        edges[[length(edges)+1]] <- c(i,j)
      }
    }
  }
  
  #Create an empty graph and then adding edges
  clq.graph <- make_empty_graph(n = length(clq)) %>% add_edges(unlist(edges))
  if (!is.simple(clq.graph)) {
    clq.graph <- simplify(clq.graph)
  }
  V(clq.graph)$name <- seq_len(vcount(clq.graph))
  
  
  comps <- decompose.graph(clq.graph)
  
  comps <- lapply(comps, function(x) {
    unique(unlist(clq[ V(x)$name ]))
  })
  
  # create dataframe with node names and community name (CPM_K[k]_number)
  comp_n <- unlist(lapply(comps, function(x) length(x)))
  comp_nr <- seq(1:length(comp_n))
  comp_nrs <- rep(comp_nr, comp_n)
  comp_list <- unlist(comps)
  commu <- cbind(comp_nrs,comp_list)
  colnames(commu) <- c("com","id")
  com_all <- merge(commu,node, by="id")
  com_all <- com_all  %>% mutate(com_name = paste0("CPM_K", k, "_", formatC(com, width=2, flag="0")))
  com_all <- com_all %>% select(node, com_name)  
  com_all <- com_all %>% arrange(com_name, node)  
  
}
