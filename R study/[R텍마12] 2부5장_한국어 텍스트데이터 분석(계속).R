####################################################################################################
# 1. 필요패키지 준비
####################################################################################################

# --------------------------------------------------
# 1.1 한글자연어처리 KoNLP패키지 설치 & 로딩
# --------------------------------------------------

# 사용중인 PC운영체제에 맞는 자바실행환경이 어느 경로에 설치되어 있는지 경로명을 자바홈 디렉토리로 설정함
Sys.setenv(JAVA_HOME = 'C:/Program Files/Java/jre1.8.0_201')

# KoNLP 한글자연어처리 패키지 인스톨
install.packages('KoNLP')

# 패키지 설치시 특정한 라이브러리 폴더를 직접지정해서 저장하는 방법
# => install.packages("zoo", lib="C:/software/Rpackages")

# 특정패키지 설치시연결되어 있는 다른 패키지도 같이 다운/설치하며, 다운로드시 접속하는 CRAN사이트를 별도로 지정하하는 방법 
# => install.packages(new_pkg, dependencies = TRUE, repos="http://R-Forge.R-project.org")

# KoNLP 한글자연어처리 패키지 메모리로 로딩
library(KoNLP)

# 패키지 로딩시에 특정한 폴더에 있는 라이브러리를 직접지정해서 로딩하는 방법
# => library("zoo", lib.loc="C:/software/Rpackages")

# --------------------------------------------------
# 1.2 여러 패키지 동시 인스톨 & 로딩
# --------------------------------------------------
# - 가급적 KoNLP패키지를 먼저 인스톨할 수 있도록 배치순서를 제일먼저 설정함

# 필요한 패키지 목록 생성
pkg <- c( 'KoNLP', 'stringr', 'magrittr', 'purrr', 'dplyr', 'tm', 'RWeka')

# 필요패키지 설지여부를 체크해 미설치패키지 목록을 저장
new_pkg <- pkg[!(pkg %in% rownames(installed.packages()))]

# 미설치 패키지 목록이 1개라도 있으면, 일괄 인스톨 실시
if (length(new_pkg)) install.packages(new_pkg, dependencies = TRUE)
# if (length(new_pkg)) install.packages(new_pkg, dependencies = TRUE, repos="http://R-Forge.R-project.org")

# 필요패키지를 일괄 로딩실시
suppressMessages(sapply(pkg, require, character.only = TRUE))  
# - suppressMessages() 함수를 통해 패키지 로딩시 나타나는 복잡한 설명/진행상황 문구 출력억제

####################################################################################################
# 2. 작업경로 정보확인
####################################################################################################

# 현재 작업경로 확인
getwd() %>% print

# 작업경로내 폴더목록과 파일목록 조회
dir() %>% print
# - 서브폴더와 서브폴더내 파일목록은 보이지 않음

# 작업경로내 폴더목록만 조회
list.dirs(recursive = F) %>% print

# 작업경로내 폴더목록과 각 폴더별 하위 폴더목록까지 조회
list.dirs(recursive = T) %>% print

# 특정 패턴을 갖는 폴더&파일 목록 존재여부 체크
file.exists("data") %>% print

# 특정한 패턴을 갖는 폴더&파일 목록 조회
dir(pattern = 'data') %>% print

# 특정 폴더내 서브폴더 목록 조회
list.dirs(path = './datatm') %>% print

# 작업경로내 파일목록과 폴더목록 조회
list.files(recursive = F) %>% print

# 작업경로내 파일목록과 각 폴더별 파일목록을 일괄 조회
list.files(recursive = T) %>% print

# 특정 폴더내 서브폴더 목록 조회
list.dirs(path = './datatm') %>% print
cat('\n')
# 특정 폴더내 파일 목록 조회
list.files (path = "./datatm/ymbaek_papers_kor") %>% print

####################################################################################################
# 3. 텍스트셋 준비 (p.113)
# - 코퍼스객체를 저정한 .Rdata파일을 로딩
####################################################################################################

# 준비된 코퍼스객체 데이터파일 로딩
load('./datatm/ymbaek_papers_kor.Rdata')
# - ymbaek_papers_en.Rdata이라는 데이터파일에 myraw와 my_pp라는 코퍼스객체가 묶여 있음

# 메모리에 로딩된 코퍼스객체 확인
ls()
# - ymbaek_papers_en.Rdata이라는 데이터파일이 로딩되면서, 
#   같이 묶여 있던 myraw(전처리전 원본코퍼스객체)와 my_pp(전처리 작업적용한 코퍼스객체)라는 
#   코퍼스객체가 각각 별도 객체로 메모리 상에 존재함 


####################################################################################################
# 4. 알파벳문자(alphabet character) 처리 (p.144)
####################################################################################################
# - 한글텍스트마이닝 상황에서는 한글문자가 초점이며, 
#   중간중간 사용되는 알파벳을 활용한 단어/문구 표현 등은 부가적인 요소임
# - 한글단어/문구를 부연설명하기 위해 사용한 영어단어는 중복표현이므로 
#   일반적으로 삭제하여 한글로만 문서단어 분석을 진행함
# - 다만, 알파벳사용문구나 영어단어 자체가 한글표현없이 텍스트셋에서 중요한 빈도를 차지하는 경우 
#   적절한 한글단어로 변환해 분석에 포함시킴
# - 또한 오히려 알파벳포함 문구를 한글로 전환했을 때 원래문구가 주는 의미가 희석되는 경우
#   (특히 소셜상의 표현 등)에는 알파벳사용문구나 영어단어를 그대로 유지해 
#   보다 명확한 의미전달이 될 수 있도록 해야함

# --------------------------------------------------
# 4.1 검색패턴을 이용한 텍스트셋 탐색
# --------------------------------------------------

# 4.1.1  알파벳 포함 검색패턴 설정 --------------------

# 알파벳 포함 검색패턴 설정
src <- '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}'
# 가운데 [[:alpha:]]{1,} ==> 알파벳에 해당하는 요소가 1개 이상 들어 있는 패턴검색 ==> [[A-z]]+, [[A-Za-z]]+ 동일검색패턴
# 양끝쪽 [[:graph:]]{0,} ==> 알파벳이 1개이상 있는 패턴 전후로 어떠한 문자가 오는지 패턴검색 ==> [[:graph:]]* 동일검색패턴

# 4.1.2  알파벳 검색패턴을 통한 텍스트셋 탐색 --------------------

# 4.1.2.1  각 문서별 검색패턴 일치내용 파악 --------------------

sprintf('말뭉치 문서별 알파벳 패턴 포함여부를 content항목에서 출현내용으로 파악:')
sapply(my_pp_tolw, str_extract_all, pattern = src) %>% print
# - sapply(my, gregexpr, pattern = src) %>% regmatche s(x = my) %>% print 동일결과
# - 앞서 (공백2칸을 1칸으로) + (숫자표현을 일괄삭제) + (대소문자를 통일) 전처리된 my_pp_tolw 코퍼스객체를 사용함
# - 말뭉치를 구성하는 각 문서별로 검색패턴과 일치하는 알파벳 출현 실제내용을 파악함
# - 검색패턴에 해당하는 알파벳 표현이 해당 텍스트요소에 들어 있지 않으면 character(0)을 출력함

# 4.1.2.2  말뭉치 전체내용 중 검색패턴 일치내용 빈도수 파악 --------------------

sprintf('전체 말뭉치에서 알파벳 패턴 출현내용을 문자순서 기준 정렬:')
sapply(my_pp_tolw, str_extract_all, pattern = src) %>% 
    unlist %>% table %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   검색패턴과 일치하는 아파벳 실제내용을 문자순서를 기준으로 정렬해 파악함

sprintf('전체 말뭉치에서 알파벳 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
sapply(my_pp_tolw, str_extract_all, pattern = src) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   검색패턴과 일치하는 실제 알파벳 내용의 출현빈도수를 기준으로 내림차순으로 정렬해 파악함

# 4.1.2.3  각 문서별 검색패턴 일치내용을 데이터프레임 구조로 파악 --------------------

# 전체 말뭉치에서 알파벳 패턴 출현내용을 별도의 임시변수에 저장
my_pp_tb <- sapply(my_pp_tolw, str_extract_all, pattern = src) %>% unlist %>% table
my_pp_tb

# 전체 말뭉치에서 알파벳 패턴 출현내용을 별도의 데이터프레임 객체로 저장
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% print %>% nrow

# 전체 말뭉치에서 알파벳 패턴 출현내용을 빈도수를 기준으로 내림차순 정렬
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 전체 말뭉치에서 알파벳 패턴 출현내용을 일정수준 이상의 빈도수를 기준으로 내림차순 정렬
my_pp_df %>% arrange(desc(freq), term) %>% filter(freq >= 5) %>% print

# --------------------------------------------------
# 4.2  텍스트셋 탐색결과에 따른 전처리 수행
# --------------------------------------------------
# - 대부분의 알파벳이 들어간 표현들은 한글문구의 보완적인 이해를 돕기위한 표현으로 나타나 
#   일괄 삭제하면 될 것으로 판단함
# - 다만, 일부 한글문구없이 사용된 영어단어/표현들 중 별도로 의미분석이 필요한 경우에는 
#   한글단어로 변경하여 문서단어분석에 활용토록 함

# - csr => 기업의사회적책임(corporate social responsibility)
# - sns => 소셜네트워크서비스(social network service)
# - tv => 텔레비전(television)
# - hlc ==> 건강통제위(health locus of control)

# 4.2.1  tm패키지에 일반함수를 이용한 전처리 --------------------
# 4.2.1.1  알파벳 포함 표현중 한글단어로 변경해야할 사항 전처리 --------------------

# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 1:1 직접변환방식
# - rmaz: remove a to z
# - 앞서 영어대문자가 소문자로 전처리된 my_pp_tolw 코퍼스객체를 사용함

my_pp_rmaz <- tm_map(my_pp_tolw, content_transformer(str_replace_all), 
                     pattern = 'csr', replacement = '기업의사회적책임')

my_pp_rmaz <- tm_map(my_pp_rmaz, content_transformer(str_replace_all), 
                     pattern = 'sns', replacement = '소셜네트워크서비스')

my_pp_rmaz <- tm_map(my_pp_rmaz, content_transformer(str_replace_all), 
                     pattern = 'tv', replacement = '소셜네트워크서비스')

my_pp_rmaz <- tm_map(my_pp_rmaz, content_transformer(str_replace_all), 
                     pattern = 'hlc', replacement = '건강통제위')

class(my_pp_rmaz)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 1:1 직접변환방식으로 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_rmaz , str_extract_all, pattern = 'csr|sns|tv|hlc') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 1:1 직접변환대상방식으로 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_rmaz, str_extract_all, pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 4.2.1.2  알파벳 포함 나머지 표현들을 일괄 삭제하는 전처리 --------------------
# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 1:1 직접변환방식
# - rmaz: remove a to z
# - 앞서 일파벳표현중 중요 문구를 한글로 전처리한 my_pp_rmaz 코퍼스객체를 사용함

my_pp_rmaz <- tm_map(my_pp_rmaz, content_transformer(str_replace_all), 
                     pattern = '[[A-z]]{1,}', replacement = '')

# (주의!!!)
# pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 알파벳 철자가 오는 문구 표현 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[[A-z]]{1,}' 
#            ==> 알파벳이 사용된 부문만을 설정하여 탐색해 전처리할 수 있도록 함

class(my_pp_rmaz)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_rmaz , str_extract_all, pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 4.2.2  stringr패키지를 이용한 전처리 --------------------
# 4.2.2.1  알파벳 포함 표현중 한글단어로 변경해야할 사항 전처리 --------------------

# stringr::str_replace_all() 함수를 이용한 전처리
# - 이 결과로 코퍼스(말뭉치)객체가 문자열객체로 변환되어, 
#   tm패키지 전처리함수 적용을 하려면 다시 말뭉치객체로 만드는 작업이 필요함

# 1:1 직접변환방식
# - eraz: erase a to z
# - 앞서 영어대문자가 소문자로 전처리된 my_pp_tolw 코퍼스객체를 사용함

my_pp_eraz <- sapply(my_pp_tolw, str_replace_all, 
                     pattern = 'csr', replacement = '기업의사회적책임')

my_pp_eraz <- sapply(my_pp_eraz, str_replace_all, 
                     pattern = 'sns', replacement = '소셜네트워크서비스')

my_pp_eraz <- sapply(my_pp_eraz, str_replace_all, 
                     pattern = 'tv', replacement = '소셜네트워크서비스')

my_pp_eraz <- sapply(my_pp_eraz, str_replace_all, 
                     pattern = 'hlc', replacement = '건강통제위')

class(my_pp_tolw)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 1:1 직접변환방식으로 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_eraz , str_extract_all, pattern = 'csr|sns|tv|hlc') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 1:1 직접변환대상방식으로 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_eraz, str_extract_all, pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 4.2.2.2  알파벳 포함 나머지 표현들을 일괄 삭제하는 전처리 --------------------
# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 1:1 직접변환방식
# - eraz: eraz a to z
# - 앞서 일파벳표현중 중요 문구를 한글로 전처리한 my_pp_eraz 코퍼스객체를 사용함

my_pp_eraz <- sapply(my_pp_eraz, str_replace_all, 
                     pattern = '[[A-z]]{1,}', replacement = '')

# (주의!!!)
# pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 알파벳 철자가 오는 문구 표현 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[[A-z]]{1,}' 
#            ==> 알파벳이 사용된 부문만을 설정하여 탐색해 전처리할 수 있도록 함


class(my_pp_eraz)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 알파벳 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_eraz , str_extract_all, pattern = '[[:graph:]]{0,}[[A-z]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print


####################################################################################################
# 5. 문장부호(punctuation marks)와 특수문자(special characters) 제거 (p.141)
####################################################################################################
# - 텍스트셋에는 많은 문장부호들이 사용되며, 각 문장부호는 고유한 문법적인 기능과 의미를 담고 있음
# - 문장부호인 마침표(.), 콤마(,), 콜론(:), 세미콜론(;), 특수문자인 !@#$%^&*()-_+=/<> 등을 상황에 따라 제거필요

# --------------------------------------------------
# 5.1  검색패턴을 이용한 텍스트셋 탐색
# --------------------------------------------------

# 5.1.1  문장부호&특수문자 검색패턴 설정 --------------------

src <- '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}'
# - 가운데 [[:punct:]]{1,} ==> 문장부호&특수문자에 해당하는 요소가 1개 이상 들어 있는 패턴검색 ==> [[:punct:]]+ 동일검색패턴
# - 양끝쪽 [[:graph:]]{0,} ==> 문장부호&특수문자가 1개이상 있는 패턴 전후로 어떠한 문자가 오는지 패턴검색 ==> [[:graph:]]* 동일검색패턴

# 5.1.2  문장부호&특수문자 검색패턴을 통한 텍스트셋 탐색 --------------------
# 5.1.2.1  각 문서별 검색패턴 일치내용 파악 --------------------

sprintf('말뭉치 문서별 문장부호&특수문자 패턴 포함여부를 content항목에서 출현내용으로 파악:')
sapply(my_pp_rmaz, str_extract_all, pattern = src) %>% print
# - sapply(my, gregexpr, pattern = src) %>% regmatche s(x = my) %>% print 동일결과
# - 앞서 앞파벳이 포함된 표현들을 한글단어로 또는 일괄삭제하는 방식으로 전처리한 my_pp_rmaz 코퍼스객체를 사용함
# - 말뭉치를 구성하는 각 문서별로 검색패턴과 일치하는 문장부호&특수문자 출현 실제내용을 파악함
# - 검색패턴에 해당하는 문장부호&특수문자 표현이 해당 텍스트요소에 들어 있지 않으면 character(0)을 출력함

# 5.1.2.2  말뭉치 전체내용 중 검색패턴 일치내용 빈도수 파악
sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 문자순서 기준 정렬:')
sapply(my_pp_rmaz, str_extract_all, pattern = src) %>% 
    unlist %>% table %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   검색패턴과 일치하는 문장부호&특수문자들의 실제내용을 문자순서를 기준으로 정렬해 파악함

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
sapply(my_pp_rmaz, str_extract_all, pattern = src) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   검색패턴과 일치하는 실제 문장부호&특수문자 내용의 출현빈도수를 기준으로 내림차순으로 정렬해 파악함

# 5.1.2.3  각 문서별 검색패턴 일치내용을 데이터프레임 구조로 파악
# 전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 별도의 임시변수에 저장
my_pp_tb <- sapply(my_pp_rmaz, str_extract_all, pattern = src) %>% unlist %>% table
my_pp_tb

# 전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 별도의 데이터프레임 객체로 저장
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% print %>% nrow

# 전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수를 기준으로 내림차순 정렬
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 일정수준 이상의 빈도수를 기준으로 내림차순 정렬
my_pp_df %>% arrange(desc(freq), term) %>% filter(freq >= 5) %>% print

# --------------------------------------------------
# 5.2  텍스트셋 탐색결과에 따른 전처리 방향성 설정
# --------------------------------------------------

# 문장부호&특수기호를 일률적으로 삭제하기 보다는, 특정 문장부호&특수기호가 그냥 삭제되었을 때 
# 의미해석이 어려운 경우를 감안하여 문장부호&특수기호 중 중요한 패턴들에 대해서 세부적으로 전처리를 진행함

# 문구에 하이픈hypen(-) 유형 표시가 있는 경우 
# - 단어와 단어사이를 연결해주는 짧은하이픈(-), 긴하이픈(－), 대시Dash(ㅡ) 기호들을 
#   모두 탐색해서 전처리를 진행함 
# - 대체로 하이픈기호가 포함된 문구는 연결된 단어들이 서로결합되어 
#   하나의 표현을 구성하는 경우로 간주해 하이픈을 없애고 하나의 단어로 만들도록 함 
# - 단, 하이픈 기호 전후로 있는 단어들이 연결어로서의 의미보다는 독립적 단어로서 
#   더 의미가 강한 경우에는 하이픈 기호를 중심으로 연결된 단어들을 분리하는 것이 바람직함

# 문구에 슬래시( / ) 표시가 있는 경우 
# - 대체로 슬래시기호가 포함된 문구는 연결된 단어들이 서로결합되어 하나의 표현을 구성하는 경우보다는
#   슬래시 기호자체가 OR조건처럼 기능을 하는 경우가 많아, 슬래시를 기준으로 각각 단어로 분리하도록 함 
# - 단, 슬래시기호 전후로 있는 단어들이 분리되어 독립어로서 의미를 가지는 것보다는 
#   연결어로서의 의미가 강한 경우에는 슬래시기호를 삭제하되 전후로 연결된 단어를 하나의 단어로 만드는 것이 필요함

# 정규표현식 방식이 아닌 1:1 직접변환방식으로 특정문구를 다른 문구로 변경 
# - 특정한 문구에 대한 전처리시에 정규표현식 사용이 복잡하고, 해당 패턴도 적은 경우에는 
#   1:1 직접변환방식으로 상황에 따라 변경/삭제함

# 남은 문장부호와 특수문자 일괄제거 
# - 남아 있는 문장부호와 특수문자는 특별한 의미가 없고, 순수한 단어분해에 방해가 되므로 일괄 삭제처리함

# --------------------------------------------------
# 5.3  문구에 하이픈hypen(-) 유형 표시가 있는 경우¶
# --------------------------------------------------
# - 단어와 단어사이를 연결해주는 짧은하이픈(-), 긴하이픈(－), 대시Dash(ㅡ) 기호들을 모두 탐색해서 전처리를 진행함

# 5.3.1  문구에 하이픈(-) 유형표시가 있는 패턴탐색 --------------------

# 전체 말뭉치에서 문장부호&특수문자 패턴 중 특정한 출현내용을 별도로 확인
my_pp_df %>% arrange(desc(freq), term) %>% 
    filter(str_detect(term, pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}')) %>% print

# 정규표현식
# - 가운데 [-－ㅡ]{1,} ==> 텍스트셋에 존재하는 짧은하이픈(-) 또는 긴하이픈(－), 대시)(ㅡ)라는 
#                          3가지 기호들이 있는지를 or조건으로 탐색하는 패턴 ==> [-－ㅡ]{1,}+ 동일 검색패턴
# - 양끝쪽 [[:graph:]]{0,} ==> 하이픈 기호 양쪽에 연결되어 있는 문구확인 ==> [[:graph:]]* 동일검색패턴

# 전처리 방향
# - 대체로 하이픈기호가 포함된 문구는 연결된 단어들이 서로결합되어 하나의 표현을 구성하는 경우로 간주해 
#   하이픈을 없애고 하나의 단어로 만들도록 함
# - 단, 하이픈 기호 전후로 있는 단어들이 연결어로서의 의미보다는 독립적 단어로서 더 의미가 강한 경우에는
#   하이픈 기호를 중심으로 연결된 단어들을 분리하는 것이 바람직함
#   (예: 주재국-대사관-본국간의, 진보-보수)
# - 하이픈기호가 포함된 문구 중에서도 별도로 문장부호&특수기호가 포함되어 있는 경우에는
#   일단 하이픈기호를 중심으로 연결된 단어를 분리하고나서, 
#   일괄적으로 주변의 다른 문장부호&특수기호를 제거하는 작업을 실시하기로 함

# 5.3.2  tm패키지에 일반함수를 이용한 전처리 --------------------
# 5.3.2.1  하이픈 유형기호 일괄삭제 대신 하이픈 기호를 중심으로 분리 --------------------

# 하이픈 유형의 기호들을 일괄삭제하는 대신 하이픈 유형기호를 중심으로 연결된 단어들을 분리
# - 하이픈 기호 전후로 있는 단어들이 연결어로서의 의미보다는 독립적 단어로서 더 의미가 강한 경우에는
#   하이픈 기호를 중심으로 연결된 단어들을 먼저 분리해서 별도로 처리하는 것이 바람직함

# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식으로 
#   이 결과로 코퍼스(말뭉치)객체형식이 유지되어 tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 입력된 전처리 대상 객체
# - 앞서 알파벳이 포함된 표현 중 중요부분은 한글단어로, 나머지 알파벳표현은 일괄 삭제하는 방식으로 전처리된 
#   my_pp_rmaz 코퍼스객체를 투입하여 my_pp_pmsc(punctuation marks & special character)라는 이름의 코퍼스객체를 계속유지시킴

my_pp_pmsc <- tm_map(my_pp_rmaz, content_transformer(str_replace_all), 
                     pattern = '주재국-대사관-본국간의', replacement = '주재국 대사관 본국')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '진보-보수', replacement = '진보 보수')

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 하이픈 유형기호가 사용된 문구 중에서 연결된 단어들을 분리하는 방식으로 전처리된 결과
sapply(my_pp_pmsc , str_extract_all, pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum
# - 하이픈 유형기호를 중심으로 연결된 단어를 한 단어로 결합해야하는 패턴은 계속 남아 있음을 알 수 있음

# 5.3.2.2  나머지 하이픈기호 사용표현을 일괄삭제하고, 전후로 있는 단어를 연결해 한개 단어로 만듬

# 하이픈기호를 일괄삭제해 전후로 있는 단어를 연결해 한개 단어로 만듬

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '[-－ㅡ]{1,}', replacement = '')
# - pmsc: punctuation marks & special character
# - 앞서 하이픈기호 일괄삭제 대신 하이픈 기호를 중심으로 분리 전처리한 my_pp_pmsc 코퍼스객체를 투입함
# - 코퍼스 각 문서별로 포함되어 있는 하이픈기호는 삭제하고, 전후로 연결된 단어를 하나의 결합단어로 변경해줌

# (주의!!!)
# pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 하이픈과 그 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[-－ㅡ]{1,}' ==> 하이픈이 사용된 부문만을 탐색해 전처리할 수 있도록 함

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 하이픈기호가 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmsc , str_extract_all, pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 하이픈 유형 기호가 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 5.3.3  stringr패키지를 이용한 전처리 -------------------- 

# 5.3.3.1  먼저 하이픈 유형기호 일괄삭제 대신 하이픈 기호를 중심으로 분리 --------------------

# 하이픈 유형의 기호들을 일괄삭제하는 대신 하이픈 유형기호를 중심으로 연결된 단어들을 분리
# - 하이픈 기호 전후로 있는 단어들이 연결어로서의 의미보다는 독립적 단어로서 더 의미가 강한 경우에는
#   하이픈 기호를 중심으로 연결된 단어들을 먼저 분리해서 별도로 처리하는 것이 바람직함

# stringr::str_replace_all() 함수를 이용한 전처리
# - 이 결과로 코퍼스(말뭉치)객체가 문자열객체로 변환되어, 
#   tm패키지 전처리함수 적용을 하려면 다시 말뭉치객체로 만드는 작업이 필요함

# 입력된 전처리 대상 객체
# - 앞서 알파벳이 포함된 표현 중 중요부분은 한글단어로, 나머지 알파벳표현은 일괄 삭제하는 방식으로 전처리된 
#   my_pp_rmaz 코퍼스객체를 투입하여 my_pp_pmsc(punctuation marks & special character)라는 이름의 코퍼스객체를 계속유지시킴

my_pp_pmnsc <- sapply(my_pp_rmaz, str_replace_all, 
                      pattern = '주재국-대사관-본국간의', replacement = '주재국 대사관 본국')

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '진보-보수', replacement = '진보 보수')

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 하이픈 유형기호가 사용된 문구 중에서 연결된 단어들을 분리하는 방식으로 전처리된 결과
sapply(my_pp_pmnsc , str_extract_all, pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum

# 5.3.3.2  이어서 하이픈기호를 일괄삭제해 전후로 있는 단어를 연결해 한개 단어로 만듬
# 하이픈기호를 일괄삭제해 전후로 있는 단어를 연결해 한개 단어로 만듬

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '[-－ㅡ]{1,}', replacement = '')
# - pmnsc: punctuation marks and special character
# - 앞서 하이픈기호 일괄삭제 대신 하이픈 기호를 중심으로 분리 전처리한 my_pp_pmnsc 코퍼스객체를 투입함
# - 코퍼스 각 문서별로 포함되어 있는 하이픈 유형기호는 삭제하고, 전후로 연결된 단어를 하나의 결합단어로 변경해줌

# (주의!!!)
# pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 하이픈과 그 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[-－ㅡ]{1,}' ==> 하이픈이 사용된 부문만을 탐색해 전처리할 수 있도록 함

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 하이픈기호가 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmnsc , str_extract_all, pattern = '[[:graph:]]{0,}[-－ㅡ]{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 하이픈기호가 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmnsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# --------------------------------------------------
# 5.4  문구에 슬래시( / ) 표시가 있는 경우
# --------------------------------------------------

# 5.4.1  문구에 슬래시( / ) 표시가 있는 패턴탐색 --------------------

# 전체 말뭉치에서 문장부호&특수문자 패턴 중 특정한 출현내용을 별도로 확인
my_pp_df %>% arrange(desc(freq), term) %>% 
    filter(str_detect(term, pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}')) %>% print

# 정규표현식
# - 가운데 /{1,} ==> 텍스트셋에 존재하는 슬래시 기호를 찾는 검색패턴 ==> /* 동일검색패턴
# - 양끝쪽 [[:graph:]]{0,} ==> 슬래시 기호 양쪽에 연결되어 있는 문구확인 ==> [[:graph:]]* 동일검색패턴

# 전처리 방향
# - 대체로 슬래시기호가 포함된 문구는 연결된 단어들이 서로결합되어 하나의 표현을 구성하는 경우보다는  
#   슬래시 기호자체가 OR조건처럼 기능을 하는 경우가 많아, 슬래시를 기준으로 각각 단어로 분리하도록 함
# - 단, 슬래시기호 전후로 있는 단어들이 분리되어 독립어로서 의미를 가지는 것보다는 연결어로서의 의미가 강한 경우에는
#   슬래시기호를 삭제하되 전후로 연결된 단어를 하나의 단어로 만드는 것이 필요함
#   (예: 방법/을, 빈도/방식의, 온/오프라인, 이념/성향과)
# - 슬래시기호가 포함된 문구 중에서도 별도로 문장부호&특수기호가 포함되어 있는 경우에는
#   일단 슬래시기호를 중심으로 연결된 단어를 분리 또는 결합하고나서, 
#   일괄적으로 주변의 다른 문장부호&특수기호를 제거하는 작업을 실시하기로 함

# 5.4.2  tm패키지에 일반함수를 이용한 전처리 --------------------
# 5.4.2.1  먼저 슬래시기호 중심으로 연결된 단어를 결합 --------------------

# 슬래시기호 중심으로 연결된 단어 일괄분리 대신 슬래시 기호를 중심으로 단어를 결합
# - 슬래시 기호 전후로 있는 단어들이 연결어로서의 의미가 강할 때에는 슬래시기호를 삭제하면서
#   전후로 연결된 단어들을 먼저 결합해 하나의 단어로 만들어 주는 것이 좋음
# - tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식으로 
#   이 결과로 코퍼스(말뭉치)객체형식이 유지되어 tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 입력된 전처리 대상 객체
# - 앞서 하이픈 유형기호들을 tm_map()에 일반함수를 사용해 전처리한 my_pp_pmsc 코퍼스 객체를 투입함


my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '방법/을', replacement = '방법')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '빈도/방식의', replacement = '빈도방식')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '온/오프라인', replacement = '온오프라인')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '이념/성향과', replacement = '이념성향')

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 슬래시기호 중심으로 연결된 단어들을 일괄분리 대신 슬래시 기호를 중심으로 단어를 결합전처리한 결과
sapply(my_pp_pmsc , str_extract_all, pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print
# - 슬래시기호를 중심으로 연결된 단어를 독립단어로 분리해야 하는 패턴은 계속 남아 있음을 알 수 있음


# 5.4.2.2  이어서 슬래시기호 중심으로 연결된 단어를 별도의 독립단어로 분리 --------------------

# 슬래시 기호를 일괄 공백으로 변환해 전후로 있는 단어를 독립적인 개별 단어로 만듬

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '/{1,}', replacement = ' ')
# - 앞서 슬래시기호 중심으로 연결된 단어를 결합전처리한 my_pp_pmsc 코퍼스객체를 투입함
# - 코퍼스 각 문서별로 포함되어 있는 슬래시기호를 공백1칸으로 변환하여, 
#   전후로 연결된 단어들이 개별적인 독립단어로 구성될 수 있도록 변경해줌

# (주의!!!)
# pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 슬래시기호와 그 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '/{1,}' ==> 슬래시기호가 사용된 부문만을 탐색해 전처리할 수 있도록 함

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 하이픈기호가 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmsc , str_extract_all, pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 슬래시기호가 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 5.4.3  stringr패키지를 이용한 전처리 --------------------
# 5.4.3.1  먼저 슬래시기호 중심으로 연결된 단어를 결합 --------------------

# 슬래시기호 중심으로 연결된 단어 일괄분리 대신 슬래시 기호를 중심으로 단어를 결합
# - 슬래시 기호 전후로 있는 단어들이 연결어로서의 의미가 강할 때에는 슬래시기호를 삭제하면서
#   전후로 연결된 단어들을 먼저 결합해 하나의 단어로 만들어 주는 것이 좋음

# stringr::str_replace_all() 함수를 이용한 전처리
# - 이 결과로 코퍼스(말뭉치)객체가 문자열객체로 변환되어, 
#   tm패키지 전처리함수 적용을 하려면 다시 말뭉치객체로 만드는 작업이 필요함

# 입력된 전처리 대상 객체
# - 앞서 하이픈 유형기호들을 sapply()에 일반함수를 사용해 전처리한 my_pp_pmnsc 코퍼스 객체를 투입함

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '방법/을', replacement = '방법')
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '빈도/방식의', replacement = '빈도방식')
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '온/오프라인', replacement = '온오프라인')
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '이념/성향과', replacement = '이념성향')

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 슬래시기호 중심으로 연결된 단어들을 일괄분리 대신 슬래시 기호를 중심으로 단어를 결합전처리한 결과
sapply(my_pp_pmnsc , str_extract_all, pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print
# - 슬래시기호를 중심으로 연결된 단어를 독립단어로 분리해야 하는 패턴은 계속 남아 있음을 알 수 있음

# 5.4.3.2  이어서 슬래시기호 중심으로 연결된 단어를 별도의 독립단어로 분리 --------------------

# 슬래시 기호를 일괄 공백으로 변환해 전후로 있는 단어를 독립적인 개별 단어로 만듬

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '/{1,}', replacement = ' ')
# - 앞서 슬래시기호 중심으로 연결된 단어를 결합전처리한 my_pp_pmnsc 코퍼스객체를 투입함
# - 코퍼스 각 문서별로 포함되어 있는 슬래시기호를 공백1칸으로 변환하여, 
#   전후로 연결된 단어들이 개별적인 독립단어로 구성될 수 있도록 변경해줌

# (주의!!!)
# pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 슬래시기호와 그 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '/{1,}' ==> 슬래시기호가 사용된 부문만을 탐색해 전처리할 수 있도록 함

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 하이픈기호가 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmnsc , str_extract_all, pattern = '[[:graph:]]{0,}/{1,}[[:graph:]]{0,}')  %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 슬래시기호가 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmnsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# --------------------------------------------------
# 5.5  특정문구를 직접 다른 문구로 변경
# --------------------------------------------------

# 5.5.1  정규표현식 방식이 아닌 1:1 직접변환방식으로 문구변경 대상파악 --------------------

# 전체 말뭉치에서 문장부호&특수문자 패턴 중 1:1 직접변환방식으로 직접변경할 대상

# (兩價感情) ==> 삭제
# ㄱ), ㄴ), ㄷ) ==> 삭제
# 둥근따옴표 유형 ‘ ’,“ ” ==> 곧은따옴표 '로 변환
# 넓은가운데점 · ==> 공백1칸으로 변환해 전후로 연결된 단어들을 독립단어로 분해함
# 넓은콤마 ， ==> 삭제

# - 특정한 문구에 대한 전처리시에 정규표현식 사용이 복잡하고, 해당 패턴도 적은 경우에는 
#   1:1 직접변환방식으로 상황에 따라 변경/삭제함 
# - 나머지는 tm패키지의 전용전처리 함수중에서 removePuntuation을 통해서
#   의미 없는 문장부호&특수기호는 일괄삭제하고, 단어는 단어대로 남겨지도록 처리함

# 5.5.2  tm패키지에 일반함수를 이용한 전처리 --------------------

# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 1:1 직접변환방식
# - pmsc: punctuation marks & special character
# - 앞서 문장부호&특수기호 중 점물음표 표현이 전처리된 my_pp_pmsc 코퍼스객체를 사용함

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '\\(兩價感情\\)', replacement = '')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '[ㄱㄴㄷ]\\)', replacement = '')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '(‘|’|“|”)', replacement = '\'') 

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '·', replacement = ' ')

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '，', replacement = '')

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 1:1 직접변환방식 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmsc , str_extract_all, pattern = '(\\(兩價感情\\))|([ㄱㄴㄷ]\\))|(‘|’|“|”)|(·)|(，)') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 1:1 직접변환대상 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 5.5.3  stringr패키지를 이용한 전처리 --------------------

# stringr::str_replace_all() 함수를 이용한 전처리
# - 이 결과로 코퍼스(말뭉치)객체가 문자열객체로 변환되어, 
#   tm패키지 전처리함수 적용을 하려면 다시 말뭉치객체로 만드는 작업이 필요함

# 1:1 직접변환방식
# - pmnsc: punctuation marks and special character
# - 앞서 문장부호&특수기호 중 점물음표 표현이 전처리된 my_pp_pmnsc 코퍼스객체를 사용함

# (兩價感情) ==> 삭제
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '\\(兩價感情\\)', replacement = '')

# ㄱ), ㄴ), ㄷ) ==> 삭제
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '[ㄱㄴㄷ]\\)', replacement = '')

# 둥근따옴표 유형 ‘ ’,“ ” ==> 곧은따옴표 '로 변환
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '(‘|’|“|”)', replacement = '\'') 

# 가운데점 · ==> 공백1칸으로 변환해 전후로 연결된 단어들을 독립단어로 분해함
my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '·', replacement = ' ')

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, 
                      pattern = '，', replacement = '')

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 1:1 직접변환방식 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmsc , str_extract_all, pattern = '(\\(兩價感情\\))|([ㄱㄴㄷ]\\))|(‘|’|“|”)|(·)|(，)') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 1:1 직접변환대상 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmnsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# --------------------------------------------------
# 5.6  남은 문장부호와 특수문자 일괄제거
# --------------------------------------------------

# 5.6.1  문구에 문장부호&특수문자 포함 패턴탐색 --------------------

# 전체 말뭉치에서 문장부호&특수문자 패턴 중 특정한 출현내용을 별도로 확인
my_pp_df %>% arrange(desc(freq), term) %>% 
    filter(str_detect(term, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}')) %>% print

# 정규표현식
# 가운데 [[:punct:]]{1,} ==> 문장부호&특수문자에 해당하는 요소가 1개 이상 들어 있는 패턴검색 ==> [[:punct:]]+ 동일검색패턴
# 양쪽   [[:graph:]]{0,} ==> 문장부호&특수문자가 1개이상 있는 패턴 전후로 어떠한 문자가 오는지 패턴검색 ==> [[:graph:]]* 동일검색패턴

# 전처리 방향
# - 남아 있는 문장부호와 특수문자는 특별한 의미가 없고, 순수한 단어분해에 방해가 되므로 일괄 삭제처리함

# 5.6.2  tm패키지 전용 전처리함수 이용 --------------------

# tm::tm_map()에 전용 전처리함수 옵션을 이용한 전처리 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지의 전용 전처리함수 옵션적용을 추가적으로 계속할 수 있음

my_pp_out <- tm_map(my_pp_pmsc, removePunctuation)
# - 앞서 1:1 직접변환대상 표현이 전처리된 my_pp_pmsc 코퍼스객체를 사용함
# - 코퍼스 각 문서별로 포함되어 있는 남아 있는 기타 문장부호&특수기호 표현은 삭제하는 것으로 처리함

class(my_pp_out)
# - tm패키지 tm_map()에 전용 전처리함수 옵션인 removePunctuation을 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 남은 기타 문장부호와 특수문자 문구 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_out , str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 남은 문장부호&특수문자 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_out, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 5.6.3  tm패키지에 일반함수를 이용한 전처리 --------------------
# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

my_pp_pmsc <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                     pattern = '[[:punct:]]{1,}', replacement = '')
# - 앞서 1:1 직접변환대상 표현이 전처리된 my_pp_pmsc 코퍼스객체를 사용함
# - 코퍼스 각 문서별로 포함되어 있는 남아 있는 기타 문장부호&특수기호 표현은 삭제하는 것으로 처리함

# (주의!!!)
# pattern = '[[:graph:]]{0,}(\\([[:alpha:]]\\))[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 괄호사이에 영어철자가 1개 오는 문구 표현 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[[:punct:]] 
#            ==> 문장부호&특수문자 문구표현이 사용된 부문만을 설정하여 탐색해 전처리할 수 있도록 함

class(my_pp_pmsc)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 괄호사이에 영어철자가 1개 오는 문구 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmsc , str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 남은 문장부호&특수문자 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

# 5.6.4  stringr패키지를 이용한 전처리 --------------------
# stringr::str_replace_all() 함수를 이용한 전처리
# - 이 결과로 코퍼스(말뭉치)객체가 문자열객체로 변환되어, 
#   tm패키지 전처리함수 적용을 하려면 다시 말뭉치객체로 만드는 작업이 필요함

my_pp_pmnsc <- sapply(my_pp_pmnsc, str_replace_all, pattern = '[[:punct:]]{1,}', replacement = '')
# - pmsc: punctuation marks and special character
# - 앞서 문장부호&특수기호 중 점물음표 표현이 전처리된 my_pp_pmsc 코퍼스객체를 사용함
# - 코퍼스 각 문서별로 포함되어 있는 괄호사이에 영어철자가 1개 오는 문구 표현은 삭제하는 것으로 처리함

# (주의!!!)
# pattern = '[[:graph:]]{0,}(\\([[:alpha:]]\\))[[:graph:]]{0,}' 이 옵션으로 전처리를 하면 문제발생함
# ==> 괄호사이에 영어철자가 1개 오는 문구 표현 전후로 있는 문구를 다같이 삭제하므로 원본데이터에 영향을 미침
# pattern = '[[:punct:]] 
#            ==> 문장부호&특수문자 문구표현이 사용된 부문만을 설정하여 탐색해 전처리할 수 있도록 함

class(my_pp_pmnsc)
# - stringr패키지의 문자열 전처리 함수인 str_replace_all을 이용했으므로 
#   전처리결과도 코퍼스(말뭉치) 객체형식이 사라지고 일반 리스트 객체형식으로 변형됨

# 괄호사이에 영어철자가 1개 오는 문구 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음
sapply(my_pp_pmnsc , str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

# 남은 문장부호&특수문자 표현이 사용된 문구는 전처리되어 해당되는 사항이 없음

sprintf('전체 말뭉치에서 문장부호&특수문자 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
my_pp_tb <- sapply(my_pp_pmnsc, str_extract_all, pattern = '[[:graph:]]{0,}[[:punct:]]{1,}[[:graph:]]{0,}') %>% 
    unlist %>% table %>% sort(decreasing = TRUE) 
my_pp_df <- data.frame(term = names(my_pp_tb), freq = c(my_pp_tb), row.names = NULL)
my_pp_df %>% dplyr::arrange(desc(freq), term) %>% print

####################################################################################################
# 6. 엔그램(N-gram) 분석
####################################################################################################
# - Ngram이란 2개 이상의 별개 단어들이 연속된 단어문구를 구성해 
#   마치 하나의 단어처럼 별도의 의미를 가지는 패턴을 분석하는 기법임
# - Weka(메카)라는 Java기반으로 작성된 라이브러리를 R기반에서 사용할 수 있도록 한 RWeka패키지를 사용함

# --------------------------------------------------
# 6.1 bigram(2-gram) 분석
# --------------------------------------------------

# 6.1.1 말뭉치에서 bigram(2-gram) 패턴 탐색 --------------------

# tm::tm_map()함수에 RWeka::NGramTokenizer()를 일반 전처리함수로 입력해 엔그램 패턴을 탐색 
my_pp_bigram <- tm_map(my_pp_pmsc, content_transformer(NGramTokenizer), Weka_control(min = 2, max = 2))
my_pp_bigram

# - 도출된 엔그램은 코퍼스객체 형식을 계속 유지하고 있음

# 코퍼스객체를 활용한 엔그램패턴 탐색결과의 내부구조정보 확인
str(my_pp_bigram)
# - 각 문서별로 $content라는 세부리스트항목에 엔그램패턴으로 파악된 문구들이 여러 개 추출되었음을 알 수 있음


# 4.1.2  말뭉치에서 bigram(2-gram) 패턴 분석 --------------------
# 4.1.2.1  말뭉치 각 문서별 bigram(2-gram) 패턴 파악 --------------------

sprintf('말뭉치 문서별 bigram 포함여부를 content항목에서 출현내용으로 파악:')
sapply(my_pp_bigram, extract, 1) %>% print %>% class
# - 말뭉치를 구성하는 각 문서별로 엔그램패턴에 해당하는 실제 문구내용을 파악함
# - 해당 문서에 엔그램 패턴으로 고려할만한 것이 없으면 character(0)을 출력함
# - 일부 엔그램 문구를 보면, 단어철자들이 생략된채로 낯선 문구로 나오는데, 
#   앞서 어근동일화 전처리기법을 적용한 코퍼스객체를 사용했기 때문임
# - 따라서 어근동일화 전처리를 하지 않고, 먼저 엔그램을 적용한 다음에 어근동일화 처리를 진행하는 시나리오도 가능함

# 4.1.2.2  말뭉치 전체내용 중 bigram(2-gram) 빈도수 파

sprintf('전체 말뭉치에서 엔그램 패턴 출현내용을 문자순서 기준 정렬:')
sapply(my_pp_bigram, extract, 1) %>%  unlist %>% table %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   엔그렘패턴으로 고려할만한 실제내용을 문자순서를 기준으로 정렬해 파악함

# 4.1.2.3  말뭉치 전체내용 중 bigram(2-gram) 빈도수 정렬

sprintf('전체 말뭉치에서 엔그램 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
sapply(my_pp_bigram, extract, 1) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   엔그렘패턴으로 고려할만한 실제내용의 출현빈도수를 내림차순으로 정렬해 파악함

# 4.1.2.4  말뭉치 전체내용 중 bigram(2-gram)을 데이터프레임 구조로 파악

# 전체 말뭉치에서 엔그램 패턴 출현내용을 별도의 임시변수에 저장
my_pp_bigram_tb <- sapply(my_pp_bigram, extract, 1) %>% unlist %>% table
my_pp_bigram_tb

# 전체 말뭉치에서 엔그램 패턴 출현내용을 별도의 데이터프레임 객체로 저장
my_pp_bigram_df <- data.frame(bigram = names(my_pp_bigram_tb), 
                             freq = c(my_pp_bigram_tb), 
                             row.names = NULL)
my_pp_bigram_df %>% print

# 전체 말뭉치에서 엔그램패턴 출현내용을 빈도수를 기준으로 내림차순 정렬
my_pp_bigram_df %>% dplyr::arrange(desc(freq), bigram) %>% print

# 전체 말뭉치에서 엔그림 패턴 출현내용을 일정수준 이상의 빈도수를 기준으로 내림차순 정렬
my_pp_bigram_df %>% dplyr::arrange(desc(freq), bigram) %>% filter(freq >= 5) %>% print

# --------------------------------------------------
# 4.2  bigram(2-gram) 전처리
# --------------------------------------------------

# 4.2.1  말뭉치에서 bigram(2-gram) 패턴 전처리 방향성 --------------------

# bigram 인정패턴 => 언더스코어(_)기호를 이용해 1:1 직접변환방식으로 한 단어로 처리해 분석에 사용
# - 공익 연계 ==> 공익_연계(공익연계 마케팅: CRM, Cause Related Marketing)

# 나머지 bigram은 일반문구 패턴에 불과한 것으로 판단하여 그대로 단어별로 분석을 수행함

# 4.2.2  tm패키지에 일반함수를 이용한 전처리 --------------------

# tm::tm_map()에 속해 있는 전용 전처리 함수가 아니라 일반 전처리 함수를 이용한 방식 
# - 이 결과로 코퍼스(말뭉치)객체형식이 유지되어 
#   tm패키지 전처리함수 적용을 추가적으로 계속할 수 있음

# 1:1 직접변환방식
# - 앞서 .Rdata파일에서 로딩한 my_pp_pmsc라는 말뭉치객체를 인풋데이터로 사용함

my_pp_gram <- tm_map(my_pp_pmsc, content_transformer(str_replace_all), 
                    pattern = '공익 연계', replacement = '공익_연계')

class(my_pp_gram)
# - tm패키지 tm_map()에 일반 함수를 사용가능하도록 해주는 content_transformer를 이용했으므로
#   전처리결과도 코퍼스(말뭉치) 객체형식을 유지하고 있음

# 엔그램 문구를 정규표형식 문자열로 생성함
bigram <- c('공익 연계')
bigram_exp <- str_c(bigram, collapse = '|')
bigram_exp

# 기존의 코퍼스객체에는 엔그램 패턴문구가 그대로 조회됨
sapply(my , str_extract_all, pattern = bigram_exp) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print

sapply(my_pp_gram , str_extract_all, pattern = bigram_exp) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print
# - 기존 코퍼스객체에 1:1 직접변환방식으로 엔그램 문구를 구성하는 단어사에에 
#   언더스코어 기호를 삽입해 전처리하였으므로 해당 사항이 없음

# --------------------------------------------------
# 4.3 trigram(3-gram) 분석
# --------------------------------------------------

# 4.3.1 말뭉치에서 trigram(3-gram) 패턴 탐색 --------------------

# tm::tm_map()함수에 RWeka::NGramTokenizer()를 일반 전처리함수로 입력해 엔그램 패턴을 탐색 
my_pp_trigram <- tm_map(my_pp_gram, content_transformer(NGramTokenizer), Weka_control(min = 3, max = 3))
my_pp_trigram

# - 앞서 bigram 문구를 전처리한 my_pp_gram 코퍼스객체를 인풋함
# - 도출된 엔그램은 코퍼스객체 형식을 계속 유지하고 있음

# 코퍼스객체를 활용한 엔그램패턴 탐색결과의 내부구조정보 확인
str(my_pp_trigram)

# - 각 문서별로 $content라는 세부리스트항목에 엔그램패턴으로 파악된 문구들이 여러 개 추출되었음을 알 수 있음

# 4.3.2  말뭉치에서 trigram(3-gram) 패턴 분석 --------------------
# 4.3.2.1  말뭉치 각 문서별 trigram(3-gram) 패턴 파악 --------------------

sprintf('말뭉치 문서별 엔그램 포함여부를 content항목에서 출현내용으로 파악:')
sapply(my_pp_trigram, extract, 1) %>% print %>% class
# - 말뭉치를 구성하는 각 문서별로 엔그램패턴에 해당하는 실제 문구내용을 파악함
# - 해당 문서에 엔그램 패턴으로 고려할만한 것이 없으면 character(0)을 출력함
# - 일부 엔그램 문구를 보면, 단어철자들이 생략된채로 낯선 문구로 나오는데, 
#   앞서 어근동일화 전처리기법을 적용한 코퍼스객체를 사용했기 때문임
# - 따라서 어근동일화 전처리를 하지 않고, 먼저 엔그램을 적용한 다음에 어근동일화 처리를 진행하는 시나리오도 가능함

# 4.3.2.2  말뭉치 전체내용 중 trigram(3-gram) 빈도수 파악 --------------------

sprintf('전체 말뭉치에서 엔그램 패턴 출현내용을 문자순서 기준 정렬:')
sapply(my_pp_trigram, extract, 1) %>%  unlist %>% table %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   엔그렘패턴으로 고려할만한 실제내용을 문자순서를 기준으로 정렬해 파악함

# 4.3.2.3  말뭉치 전체내용 중 trigram(3-gram) 빈도수 정렬 --------------------

sprintf('전체 말뭉치에서 엔그램 패턴 출현내용을 빈도수 기준 내림차순으로 정렬:')
sapply(my_pp_trigram, extract, 1) %>% 
    unlist %>% table %>% sort(decreasing = TRUE) %>% print %>% sum
# - 말뭉치를 구성하는 각 문서가 아닌 전체 내용을 통합했을 때 
#   엔그렘패턴으로 고려할만한 실제내용의 출현빈도수를 내림차순으로 정렬해 파악함

# 4.3.2.4  말뭉치 전체내용 중 trigram(3-gram)을 데이터프레임 구조로 파악 --------------------

# 전체 말뭉치에서 엔그램 패턴 출현내용을 별도의 임시변수에 저장
my_pp_trigram_tb <- sapply(my_pp_trigram, extract, 1) %>% unlist %>% table
my_pp_trigram_tb

# 전체 말뭉치에서 엔그램 패턴 출현내용을 별도의 데이터프레임 객체로 저장
my_pp_trigram_df <- data.frame(trigram = names(my_pp_trigram_tb), 
                             freq = c(my_pp_trigram_tb), 
                             row.names = NULL)
my_pp_trigram_df %>% print

# 전체 말뭉치에서 엔그램패턴 출현내용을 빈도수를 기준으로 내림차순 정렬
my_pp_trigram_df %>% dplyr::arrange(desc(freq), trigram) %>% print

# 전체 말뭉치에서 엔그림 패턴 출현내용을 일정수준 이상의 빈도수를 기준으로 내림차순 정렬
my_pp_trigram_df %>% dplyr::arrange(desc(freq), trigram) %>% filter(freq >= 5) %>% print

# - trigram 분석내용 중 의미있는 엔그램 문구는 없는 것으로 판단됨

####################################################################################################
# 전처리 결과 저장하기
####################################################################################################

save(my, my_pp_pmsc, file = './datatm/ymbaek_papers_kor_pp.Rdata')

### End of Documents ###############################################################################
