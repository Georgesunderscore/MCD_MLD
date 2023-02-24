#1- Nom des lieux qui finissent par 'um'.

SELECT * FROM lieu l
WHERE l.nom_lieu LIKE '%um';

#2- Nombre de personnages par lieu (trié par nombre de personnages décroissant).

SELECT COUNT(*) , l.nom_lieu  from personnage p
INNER JOIN lieu l ON p.id_lieu = l.id_lieu
GROUP BY l.id_lieu , l.nom_lieu 
ORDER BY COUNT(*) DESC;

#3- Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT p.nom_personnage , s.nom_specialite , p.adresse_personnage , l.nom_lieu from personnage p
INNER JOIN lieu l ON p.id_lieu = l.id_lieu
INNER JOIN specialite s ON p.id_specialite = s.id_specialite
GROUP BY p.nom_personnage , s.nom_specialite , p.adresse_personnage , l.nom_lieu 
ORDER BY  l.nom_lieu ,p.nom_personnage DESC;

#4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).

SELECT s.nom_specialite , COUNT(*) from personnage p
INNER JOIN specialite s ON p.id_specialite = s.id_specialite
GROUP BY s.nom_specialite 
ORDER BY   COUNT(*)  DESC;


#5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichéesau format jj/mm/aaaa).

SELECT b.nom_bataille, l.nom_lieu ,DATE_FORMAT(b.date_bataille,"%d/%m/-%Y") from bataille b
INNER JOIN lieu l ON b.id_lieu = l.id_lieu
ORDER BY b.date_bataille DESC;

#6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT p.nom_potion , c.qte , i.cout_ingredient from potion p
INNER JOIN composer c ON p.id_potion = p.id_potion
INNER JOIN ingredient i ON c.id_ingredient = i.id_ingredient;

#7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

SELECT i.nom_ingredient,i.cout_ingredient , c.qte  from potion p
INNER JOIN composer c ON p.id_potion = p.id_potion
INNER JOIN ingredient i ON c.id_ingredient = i.id_ingredient
WHERE p.nom_potion ="Santé";


#8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

SELECT SUM(pc.qte)  c, p.nom_personnage pnom, b.nom_bataille nomba from bataille b
INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
INNER JOIN personnage p ON pc.id_personnage = p.id_personnage
WHERE b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.nom_personnage , b.nom_bataille
HAVING c IN (SELECT MAX(t.c) FROM 
											(SELECT SUM(pc.qte)  c, p.nom_personnage pnom, b.nom_bataille nomba from bataille b
											INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
											INNER JOIN personnage p ON pc.id_personnage = p.id_personnage
											WHERE b.nom_bataille = 'Bataille du village gaulois'
											GROUP BY p.nom_personnage , b.nom_bataille) t
					);
					
					
#9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).

SELECT p.nom_personnage  , sum(b.dose_boire) sd from personnage p
INNER JOIN boire b ON p.id_personnage =b.id_personnage
INNER JOIN potion po ON b.id_potion= po.id_potion
GROUP BY p.nom_personnage  
ORDER BY sd DESC;

#10. Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT b.nom_bataille nomba , COUNT(*) c from bataille b
INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
GROUP BY b.nom_bataille
HAVING c IN (SELECT MAX(t.c) FROM 
				(SELECT b.nom_bataille nomba , COUNT(*) c from bataille b
				INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
				GROUP BY b.nom_bataille) t
				);
				
#11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)

SELECT COUNT(*) c , tc.nom_type_casque , sum(c.cout_casque) from prendre_casque pc
INNER JOIN casque c ON pc.id_casque = c.id_casque
INNER JOIN type_casque tc ON c.id_type_casque = tc.id_type_casque
GROUP BY tc.nom_type_casque
ORDER BY COUNT(*) DESC;


#12. Nom des potions dont un des ingrédients est le poisson frais.

SELECT distinct p.nom_potion FROM potion p
INNER JOIN composer c ON  p.id_potion= c.id_potion
INNER JOIN ingredient i ON  c.id_ingredient= i.id_ingredient
WHERE i.nom_ingredient = 'Poisson frais';


#13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.

SELECT l.nom_lieu ,COUNT(*) c from personnage p
INNER JOIN lieu l ON p.id_lieu = l.id_lieu
GROUP BY l.id_lieu , l.nom_lieu 
HAVING c IN (SELECT MAX(t.c) FROM 
				(SELECT l.nom_lieu ,COUNT(*) c from personnage p
				 INNER JOIN lieu l ON p.id_lieu = l.id_lieu
				 GROUP BY l.id_lieu , l.nom_lieu 
				 HAVING l.nom_lieu <> 'Village gaulois') t
				);
				
				
#14. Nom des personnages qui n'ont jamais bu aucune potion.

SELECT p.nom_personnage from personnage p
LEFT JOIN boire b ON p.id_personnage =b.id_personnage
WHERE b.id_potion IS NULL;

#15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

SELECT * FROM personnage per
WHERE per.nom_personnage NOT IN (SELECT p.nom_personnage from personnage p
											INNER JOIN autoriser_boire ab ON p.id_personnage =ab.id_personnage
											INNER JOIN potion po ON ab.id_potion=po.id_potion
											WHERE po.nom_potion = 'Magique')


