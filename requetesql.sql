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
					
#8 avec view 
CREATE OR REPLACE  VIEW CASQUES_GAULOIS_BATAILLE AS
SELECT SUM(pc.qte) total, p.nom_personnage nom from bataille b
INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
INNER JOIN personnage p ON pc.id_personnage = p.id_personnage
WHERE b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.nom_personnage;

SELECT v.nom , v.total 
FROM casques_gaulois_bataille v
HAVING v.total IN ( 
						SELECT max(v.total) 
						FROM casques_gaulois_bataille v
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

SELECT COUNT(*) AS nbCasques , tc.nom_type_casque , sum(c.cout_casque) AS total from prendre_casque pc
INNER JOIN casque c ON pc.id_casque = c.id_casque
INNER JOIN type_casque tc ON c.id_type_casque = tc.id_type_casque
GROUP BY tc.nom_type_casque
ORDER BY nbCasques DESC;


#12. Nom des potions dont un des ingrédients est le poisson frais.

SELECT distinct p.nom_potion FROM potion p
INNER JOIN composer c ON  p.id_potion= c.id_potion
INNER JOIN ingredient i ON  c.id_ingredient= i.id_ingredient
WHERE i.nom_ingredient = 'Poisson frais';


#13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.

SELECT l.nom_lieu ,COUNT(*) c from personnage p
INNER JOIN lieu l ON p.id_lieu = l.id_lieu
GROUP BY l.id_lieu , l.nom_lieu 
HAVING l.nom_lieu <> 'Village gaulois'
and c IN (
				SELECT MAX(t.c) FROM 
				(
				 SELECT l.nom_lieu ,COUNT(*) c from personnage p
				 INNER JOIN lieu l ON p.id_lieu = l.id_lieu
				 GROUP BY l.id_lieu , l.nom_lieu 
				 HAVING l.nom_lieu <> 'Village gaulois') t
				);
				
Autre VERSION pour le 13 

SELECT l.nom_lieu, COUNT(p.id_personnage) AS nb
FROM personnage p, lieu l
WHERE p.id_lieu = l.id_lieu 
AND l.nom_lieu != 'Village gaulois'
GROUP BY l.id_lieu
HAVING nb >= ALL ( 
SELECT COUNT(p.id_personnage)
        FROM personnage p, lieu l
        WHERE l.id_lieu = p.id_lieu
        AND l.nom_lieu != 'Village gaulois'
GROUP BY l.id_lieu)
				
#14. Nom des personnages qui n'ont jamais bu aucune potion. outer join left 

SELECT p.nom_personnage from personnage p
LEFT JOIN boire b ON p.id_personnage =b.id_personnage
WHERE b.id_potion IS NULL;

#15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

SELECT * FROM personnage per
WHERE per.id_personnage NOT IN (SELECT p.id_personnage from personnage p
											INNER JOIN autoriser_boire ab ON p.id_personnage =ab.id_personnage
											INNER JOIN potion po ON ab.id_potion=po.id_potion
											WHERE po.nom_potion = 'Magique')

#DML commands 

#A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.
INSERT INTO personnage (nom_personnage, adresse_personnage, id_lieu, id_specialite)
VALUES (
        'Champdeblix', 
        'Ferme Hantassion', 
        (SELECT id_lieu FROM lieu WHERE nom_lieu = 'Rotomagus'),
(SELECT id_specialite FROM specialite WHERE nom_specialite = 'Agriculteur')
)

#B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...
INSERT INTO autoriser_boire (id_potion , id_personnage)
VALUES ((SELECT p.id_potion FROM potion p WHERE p.nom_potion = 'Magique'),
			(SELECT pr.id_personnage FROM personnage pr WHERE pr.nom_personnage = 'Bonemine'))
			
#C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.
DELETE from casque c
WHERE c.id_casque not IN (select pc.id_casque FROM prendre_casque pc )

SELECT p.id_personnage ,p.id_lieu FROM personnage p
									WHERE p.nom_personnage ='Zérozérosix'  ;
									
					
#D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.

UPDATE personnage p
SET p.adresse_personnage = 'prison à Condate' , 
	 P.id_lieu = (SELECT lieu_id FROM lieu WHERE nom_lieu = 'Condate' )
WHERE p.nom_personnage ='Zérozérosix'  ;

									
#E. La potion 'Soupe' ne doit plus contenir de persil.

delete  from composer c
WHERE c.id_ingredient = (SELECT i.id_ingredient from ingredient i where i.nom_ingredient = 'Persil')
AND c.id_potion = (SELECT p.id_potion from potion p WHERE p.nom_potion = 'Soupe')

#F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !

UPDATE prendre_casque pc
SET pc.id_casque = (SELECT c.id_casque FROM casque c WHERE c.nom_casque ='Weisenau'),
    pc.qte  = 42
WHERE pc.id_bataille IN (SELECT b.id_bataille FROM bataille b
								 WHERE b.nom_bataille = 'Attaque de la banque postale')

									

