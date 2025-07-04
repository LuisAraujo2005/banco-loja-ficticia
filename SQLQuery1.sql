-----Desafios SQL (Consultas que você deve montar):

use Loja_Ficticia

--- 1.Total de Vendas por Cliente

	select 
	P.ClienteID,
	C.Nome,
	SUM(PR.PrecoUnitario) AS Total_Vendas 
	from dbo.Pedidos as P
	left join dbo.Clientes as C on P.ClienteID = C.ClienteID
	left join dbo.Produtos as PR on P.ProdutoID = PR.ProdutoID
	GROUP BY P.ClienteID, C.Nome
	ORDER BY P.ClienteID

--- 2. Produto mais vendido em quantidade

	select 
	pr.NomeProduto,
	p.quantidade
	from dbo.pedidos as p
	left join dbo.Produtos as pr on p.ProdutoID = pr.ProdutoID
	order by 2 desc

--- 3. Faturamento total por categoria

	select 
	pr.Categoria,
	sum(p.Quantidade *pr.PrecoUnitario) 
	from dbo.Pedidos as p
	left join dbo.Produtos as pr on p.ProdutoID = pr.ProdutoID
	group by pr.Categoria

--- 4. Clientes que compraram mais de R$ 1000 em pedidos
	
	select 
	p.ClienteID,
	c.nome,
	sum(p.Quantidade * pr.PrecoUnitario) as 'Soma dos valores'
	from Pedidos as p
	left join Produtos as pr on p.ProdutoID = pr.ProdutoID
	left join Clientes as c on p.ClienteID = c.ClienteID
	group by p.ClienteID, c.nome
	having sum(p.Quantidade * pr.PrecoUnitario) > 1000

--- 5. Mês com maior volume de pedidos

	select 
	pedidoid,
	datename(MONTH, DataPedido),
	sum(Quantidade)
	from Pedidos
	group by  PedidoID,datename(MONTH, DataPedido)
	order by sum(Quantidade) desc

--- 6. Ticket médio por pedido

	select 
	count(p.PedidoID) as pedidos,
	sum(pr.PrecoUnitario*p.Quantidade) as produtos,
	cast(sum(pr.PrecoUnitario*p.Quantidade) as decimal(10,2))/count (distinct p.PedidoID)
	from Pedidos as p
	left join Produtos as pr  on p.ProdutoID = pr.ProdutoID

--- 7. Top 3 produtos mais vendidos

	select *
	from(select 
	p.ProdutoID,
	pr.NomeProduto,
	sum(Quantidade) qtd_vendida,
	row_number() over (order by sum(Quantidade) desc) rank
	from Pedidos as p 
	left join Produtos as pr on p.ProdutoID = pr.ProdutoID
	group by p.ProdutoID,
	pr.NomeProduto) dados 
	where rank in (1,2,3)

--- 8. Consulta com CTE que mostra o total de compras por cliente e ordena por maior valor
	
	select 
	p.ClienteID,
	c.Nome,
	sum(p.Quantidade) qtd_comp,
	sum(pr.PrecoUnitario * p.Quantidade) total
	into ##temp_venda
	from pedidos as p 
	left join Clientes as c on p.ClienteID = c.ClienteID
	left join Produtos as pr on p.ProdutoID = pr.ProdutoID
	group by p.ClienteID,
	c.Nome
	order by total desc

	select * from ##temp_venda

--- 9. Consulta com Window Function que rankeia os produtos mais vendidos por categoria
	
	select *
	from(select 
	p.ProdutoID,
	pr.Categoria,
	pr.NomeProduto,
	sum(Quantidade) qtd_vendida,
	row_number() over (partition by pr.Categoria order by sum(Quantidade) desc) rank
	from Pedidos as p 
	left join Produtos as pr on p.ProdutoID = pr.ProdutoID
	group by p.ProdutoID,
	pr.NomeProduto, pr.Categoria) dados 

--- 10. Consulta com Subquery que retorna os clientes que compraram acima da média geral de pedidos

		SELECT 
		c.Nome,
		SUM(p.Quantidade * pr.PrecoUnitario) AS TotalComprado
	FROM Pedidos AS p 
	LEFT JOIN Clientes AS c ON p.ClienteID = c.ClienteID
	LEFT JOIN Produtos AS pr ON p.ProdutoID = pr.ProdutoID
	GROUP BY c.Nome
	HAVING SUM(p.Quantidade * pr.PrecoUnitario) > (
		SELECT AVG(Total)
		FROM (
			SELECT 
				SUM(p2.Quantidade * pr2.PrecoUnitario) AS Total
			FROM Pedidos AS p2
			LEFT JOIN Produtos AS pr2 ON p2.ProdutoID = pr2.ProdutoID
			GROUP BY p2.ClienteID
		) MediaClientes
	)
