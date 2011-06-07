Feature: Search for names

	So that a web site can provide a list of authors, editors, and publishers to the end user
	As a federated web site or an anonymous visitor
	I want to access a list of all names that match my search request

	Scenario: Do a simple name retrieval
		Given I am not authenticated
		When I names with <q=+tree&y=+1844> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/names_results.xsd"
		And the xml "authors" list is "Burke, William A.,1,Clark, Willis Gaylord, 1808-1841,1,Dante Gabriel Rossetti,1,Dickens, Charles, 1812-1870,1,Disraeli, Benjamin, Earl of Beaconsfield, 1804-1881,1,Editor,1,Fowler, Orson Squire [O. S. Fowler],1,Green, J. H.,1,Herbert, Henry William, 1807-1858,2,Ingraham, J. H. (Joseph Holt), 1809-1860,8,Lever, Charles, 1806-1872,1,Lippard, George, 1822-1854,2,Morgan, Lewis Henry, 1818-1881,1,Neal, Joseph C. (Joseph Clay), 1807-1847,1,Simms, William Gilmore, 1806-1870,1,Stuart, Charles, 1783-1865,1,Thomas, Frederick William,1,Unknown,1,Weller, John B.,1"
		And the xml "editors" list is ""
		And the xml "publishers" list is "A. J. Rockefellar,2,Atwill, 201 Broadway,1,Burgess, Stringer & Co.,1,Carey & Hart,1,Chapman and Hall, 1844. xiv,1,Darton & Clark,1,Edward P. Williams,2,F. Gleason,2,Harper and Brothers,1,Henry Colburn,1,Lee & Walker, 120 Walnut St.,1,Lee and Walker,,1,Louis A. Godey,1,New York:Fowler and Wells,c1844,1,Peabody,1,R. G. Berford,2,Vizetelly Brothers and Co.,2,William Curry, Jun. and Company,1,[s. n.],1,published at the 'Yankee' Office,3,s.l.:s.n.,1844?,1"

	Scenario: Do a name retrieval that doesn't return any results
		Given I am not authenticated
		When I names with <q=+tree+xxxyyyzz> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/names_results.xsd"
		And the xml "authors" list is ""
		And the xml "editors" list is ""
		And the xml "publishers" list is ""

	Scenario: Display a simple name retrieval
		Given I am not authenticated
		When I names with <q=+tree&y=+1844>
		Then the response status should be "200"
		And I should see "Willis Gaylord, 1808-1841"

	Scenario: Do a large name retrieval
		Given I am not authenticated
		When I names with <q=+tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/names_results.xsd"
		And the xml "authors" list starts with "&quot;Q&quot;,1,A Gentleman of Oxford,1,A Lady.,2,A' Beckett, Arthur,1,A'Beckett, Gilbert Abbot,1,A'Beckett, Gilbert Abbot and Lemon, Mark,1,A-Beckett, Gilbert Abbot,1,A. B. England,1,A. M. Baumgartner,1,A. O. Aldridge,1,A. P. Antippas,1,A. R. Coulthard,1,ANN FISHER-WIRTH,1,ANN MOSELEY,2,ANN ROMINES,1,ANN W. FISHER-WIRTH,1,ANNE GILCHRIST,1,ASAD AL-GHALITH,1,Abbot, George,1,Abbot, Larry, fl. 1994-2006,1,Abbott, Charles C.,1,Abbott, John Stevens Cabot, 1805-1877,9,Abbott, Lawrence, 1949-,4,Abbott, Lemuel Abijah, 1842-1911,1,Abbott, S. M., 1853-,1,Abell, L. G., Mrs.,1,Abercrombie, Fred, 1893-,1,Abercrombie, John,13,Aboud, James Christopher, 1956-,45,Abrahams, Peter, 1919-,8,Accum, Friedrich Christian,1,Achebe, Chinua,1,Achitoff, Lauren,1,Achsah Guibbory,1,Ackland, Michael,1,Acton, Eliza, 1799-1859.,1,Ada Long,1,Adair, Jesse, 1868-,1,Adair, William Penn, 1830-1880,1,Adam Potkay,1,Adam Roberts,1,Adams, Charles Francis, Jr., 1835-1915,5,Adams, Dicey Stake, 1879-,1,Adams, H. A., Mrs,1,Adams, John S. (John Stowell), d. 1893,1,Adams, Lawrence G., 1873-,1,Adams, Margaret Cring, 1855-,1,Adams, Mrs. [Catherine Lyman],1,Adams, W. D.,1"
		And the xml "editors" list starts with "Abbott, Megan, fl. 1995,1,Adams, Henry and Hay, Clara Louise,3,Agassiz, George R., ed.,11,Aikin, Lucy,6,Aitch, N. H.,1,Alden, Carroll Storrs,1,Alexander Mackay, 1796-1844,1,Allsop, Richard,382,Ambrose Philips,3,Ames, Blanche Butler, comp.,6,Anderson, James House and Anderson, Nancy, eds.,4,Andrew Jewell,19,Andrews, Elizabeth, fl. 2007,1,Antony H. Harrison,20,Armstrong, Mary M. Bronson,1,Arthur O'Connor, Peter Finnerty,1,Arthur Young, John Seally,3,Arthur, Kevyn Alan, 1942-,190,Ashton, Rosemary,8,Austen, Jessica, ed.,2,Babcock, Willoughby Maynard, ed.,1,Bach, Irene,29,Bacon, Georgeanna Woolsey and Howland, Eliza Woolsey, ed.,1,Bacon, Georgeanna Woolsey and Howland, Eliza Woolsey, eds.,7,Baillie, Joanna, 1762-1851,1,Bainbridge, Clare,2,Baker, William,48,Baker, William.,22,Balscopo, Giovanni Battista, 1788-1852,1,Barbara Timm Gates,8,Barrell, John, fl. 2006,4,Barrett, Paul H.,270,Barrett, Paul H. and R.B. Freeman,1,Barton, William Eleazar,2,Batchelor, Jennie, 1976-,1,Battle, Laura Elizabeth,2,Beale, Harriet S. Blaine, ed.,1,Belyakova, Lydia,48,Benis, Toby R., fl. 1997-2007,1,Berkeley, Elizabeth M.,143,Bewell, Alan, fl. 1988-2005,4,Blessington, Marguerite, Countess of,6"
		And the xml "publishers" list starts with "&quot;Daily Post&quot;, Steam Printing Works,1,&quot;University,6,'Published for Whom it May Concern',1,'Published for Whom it May ConcernO',1,'Sold by the principal booksellers',2,'printed for the author',1,'printed for the publisher',1,(first printed in 1773) Second edition with additions printed for B. White and Son, Fleet-Street; and C. Dilly, In The Poultry,1,:,1876?,1,A. Asher & Co., Unter den Linden,1,A. H. Diller,1,A. H. Maltby,1,A. H. Smythe,1,A. Hart,2,A. J. Rockefellar,2,A. Jenkins,1,A. Kroch & Son,3,A. M. Wilson,18,A. Morris,1,A. Murray and J. Cochran,1,A. Roman & Co.,1,A. Roman & Company,12,A. Simpson & Company,1,A. Strahan, and T. Cadell in the Strand; and W. Creech at Edinburgh,2,A. T. Goodrich & Co.,2,A. Tompkins and B. B. Mussey. Redding & Co.,1,A. W. Gamage,1,A.D. Worthington and Company,6,A.F. Nelson,5,A.G. Rogers, Printer,1,A.H. Sickler and Co.,1,A.L. Fowle,7,A.L. Luyster,1,A.O. Marshall,7,A.S. Barnes & Company,1,ABC,3,ALEXANDER AIKMAN,2,ALEXANDER AIKMAN, JUNIOR,1,ALFRED J. KNOPF, INC.,1,AMS Press,1,Abel Heywood & Son,2,Ackermann, R.,6,Adam and Charles Black,1,Adam and Charles Black, 1858. x,1,Adams and Dabney,1,Agnew & Deffebach Printers,1,Agnew & Deffebach, Print., Geo. W. Johnson, Phot.,2,Akashic Books,83,Albany:Weed, Parsons and Company,1867,1,Alden Brothers,1,Alden Chase Brett,3,Alden, Beardsley & Co.,1,Alex Hogg,3,Alex. Stewart,42,Alexander Street Press,50,Alexander V. Blake,20,Alexander Wilkinson,3,Alfred Gibbons,2"
